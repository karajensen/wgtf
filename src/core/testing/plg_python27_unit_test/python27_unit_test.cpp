#include "pch.hpp"

#include "core_python27/defined_instance.hpp"
#include "core_python27/listener_hooks.hpp"
#include "core_python27/scripting_engine.hpp"
#include "core_python27/script_object_definition_registry.hpp"

#include "core_python27/type_converters/converter_queue.hpp"

#include "core_reflection/object_handle.hpp"
#include "core_reflection/property_accessor.hpp"
#include "core_reflection/reflection_macros.hpp"
#include "core_reflection/reflected_method_parameters.hpp"
#include "core_reflection/i_definition_manager.hpp"

#include <longintrepr.h>

#include <string>

#include "reflection_test_module.hpp"

// Set by application
namespace wgt
{
IComponentContext* g_contextManager(nullptr);

class ScopedPythonState
{
public:
	ScopedPythonState(IComponentContext& contextManager)
	    : contextManager_(contextManager), typeConverterQueue_(contextManager),
	      hookListener_(new ReflectedPython::HookListener())
	{
		// Initialize listener hooks
		const auto pDefinitionManager = contextManager.queryInterface<IDefinitionManager>();
		if (pDefinitionManager == nullptr)
		{
			NGT_ERROR_MSG("Could not get IDefinitionManager\n");
			return;
		}
		pDefinitionManager->registerPropertyAccessorListener(
		std::static_pointer_cast<PropertyAccessorListener>(hookListener_));
		g_pHookContext = &contextManager;
		g_listener = hookListener_;

		scriptingEngine_.init();

		const bool transferOwnership = false;
		pDefinitionRegistryInterface_ = contextManager.registerInterface(&definitionRegistry_, transferOwnership);
		definitionRegistry_.init();

		typeConverterQueue_.init();
	}
	~ScopedPythonState()
	{
		typeConverterQueue_.fini();
		contextManager_.deregisterInterface(pDefinitionRegistryInterface_.get());
		definitionRegistry_.fini();
		scriptingEngine_.fini();

		// Finalize listener hooks
		// All reflected Python objects should have been removed by this point
		const auto pDefinitionManager = contextManager_.queryInterface<IDefinitionManager>();
		if (pDefinitionManager == nullptr)
		{
			NGT_ERROR_MSG("Could not get IDefinitionManager\n");
			return;
		}
		pDefinitionManager->deregisterPropertyAccessorListener(
		std::static_pointer_cast<PropertyAccessorListener>(hookListener_));
		g_listener.reset();
		g_pHookContext = nullptr;
	}

	IComponentContext& contextManager_;

	Python27ScriptingEngine scriptingEngine_;

	ReflectedPython::ScriptObjectDefinitionRegistry definitionRegistry_;
	InterfacePtr pDefinitionRegistryInterface_;

	PythonType::ConverterQueue typeConverterQueue_;
	std::shared_ptr<ReflectedPython::HookListener> hookListener_;
};

TEST(Python27)
{
	CHECK(g_contextManager != nullptr);
	if (g_contextManager == nullptr)
	{
		return;
	}
	IComponentContext& contextManager(*g_contextManager);

	auto pDefinitionManager = contextManager.queryInterface<IDefinitionManager>();
	CHECK(pDefinitionManager != nullptr);
	if (pDefinitionManager == nullptr)
	{
		return;
	}

	IDefinitionManager& definitionManager = *pDefinitionManager;

	// Must be scoped so that fini is called on each of the early returns
	ScopedPythonState scopedScriptingEngine(contextManager);
	IPythonScriptingEngine* scriptingEngine = &scopedScriptingEngine.scriptingEngine_;

	// Import a builtin module
	{
		ObjectHandle module = scriptingEngine->import("sys");
		CHECK(module.isValid());
		// Python test failed to import sys
		if (!module.isValid())
		{
			return;
		}
	}

	// Import a builtin module that uses py files
	{
		ObjectHandle module = scriptingEngine->import("os");
		CHECK(module.isValid());
		// Python test failed to import os
		if (!module.isValid())
		{
			return;
		}
	}

	// Import a builtin module which will then import a submodule
	// encodings.aliases
	{
		ObjectHandle module = scriptingEngine->import("encodings");
		CHECK(module.isValid());
		// Python test failed to import encodings or encodings.aliases
		if (!module.isValid())
		{
			return;
		}
	}

	// Import a builtin module that uses pyd files
	{
		ObjectHandle module = scriptingEngine->import("md5");
		CHECK(module.isValid());
		// Python test failed to import md5
		if (!module.isValid())
		{
			return;
		}
	}

	// Register the test module
	// The scripting engine must be shut down to de-register it.
	ReflectionTestModule reflectionModule(contextManager, "Python27Test", result_);

	// Import the test module and run it
	{
		const wchar_t* sourcePath = L"../../../src/core/testing/plg_python27_unit_test/resources/Scripts";
		const wchar_t* deployPath = L":/Scripts";
		const char* moduleName = "python27_test";
		const bool sourcePathSet = scriptingEngine->appendSourcePath(sourcePath);
		CHECK(sourcePathSet);
		const bool deployPathSet = scriptingEngine->appendBinPath(deployPath);
		CHECK(deployPathSet);
		auto module = scriptingEngine->import(moduleName);
		CHECK(module.isValid());
		// Python failed to import test script.
		if (!module.isValid())
		{
			return;
		}

		auto moduleDefinition = definitionManager.getDefinition(module);
		ReflectedMethodParameters parameters;
		auto propertyAccessor = moduleDefinition->bindProperty("run", module);
		CHECK(propertyAccessor.isValid());
		if (!propertyAccessor.isValid())
		{
			return;
		}

		auto result = propertyAccessor.invoke(parameters);
		CHECK(!result.isVoid() && !scriptingEngine->checkErrors());
		// Python failed to run test script.
	}
}
} // end namespace wgt
