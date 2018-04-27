#include "core_generic_plugin/generic_plugin.hpp"

#include "ui_test_panel_context.hpp"
#include "python_panel.hpp"
#include "core_reflection/i_definition_manager.hpp"
#include "core_python_script/i_scripting_engine.hpp"
#include "core_reflection/reflection_macros.hpp"
#include "core_object/managed_object.hpp"
#include "core_logging/logging.hpp"

#include "metadata/ui_test_panel_context.mpp"
#include "core_reflection/utilities/reflection_auto_register.hpp"

#include <memory>

WGT_INIT_QRC_RESOURCE

namespace wgt
{
ManagedObjectPtr createContextObject(IComponentContext& componentContext, const char* panelName, ObjectHandle& pythonObject)
{
	auto pDefinitionManager = componentContext.queryInterface<IDefinitionManager>();
	if (pDefinitionManager == nullptr)
	{
		NGT_ERROR_MSG("Failed to find IDefinitionManager\n");
		return nullptr;
	}

    return ManagedObject<PanelContext>::make_iunique_fn(
        [panelName, &pythonObject](PanelContext& contextObject)
    {
        if (!contextObject.initialize(panelName, pythonObject))
        {
            NGT_ERROR_MSG("Failed to initialise context object\n");
        }
    });
}

/**
* A plugin which queries the IPythonScriptingEngine to test adding and modifying components through python scripts
*
* @ingroup plugins
* @image html plg_python27_ui_test.png
* @note Requires Plugins:
*       - @ref coreplugins
*       - Python27Plugin
*/
struct Python27TestUIPlugin : public PluginMain
{
	Python27TestUIPlugin(IComponentContext& componentContext)
	{
		registerCallback([](IDefinitionManager & defManager)
		{
			ReflectionAutoRegistration::initAutoRegistration(defManager);
		});
	}

	bool PostLoad(IComponentContext& componentContext) override
	{
		return true;
	}

	void Initialise(IComponentContext& componentContext) override
	{
		auto pScriptingEngine = componentContext.queryInterface<IPythonScriptingEngine>();
		if (pScriptingEngine == nullptr)
		{
			NGT_ERROR_MSG("Failed to find IPythonScriptingEngine\n");
			return;
		}
		auto& scriptingEngine = (*pScriptingEngine);

		const wchar_t* sourcePath = L"../../../src/core/testing/plg_python27_ui_test/resources/Scripts";
		const wchar_t* deployPath = L":/Scripts";
		const char* moduleName = "test_objects";
		const bool sourcePathSet = scriptingEngine.appendSourcePath(sourcePath);
		assert(sourcePathSet);
		const bool deployPathSet = scriptingEngine.appendBinPath(deployPath);
		assert(deployPathSet);
		auto module = scriptingEngine.import(moduleName);
		if (!module.isValid())
		{
			NGT_ERROR_MSG("Could not load from scripts\n");
			return;
		}

		const char* panelName1 = "Python Test 1";
		pythonPanel1_.reset(new PythonPanel(createContextObject(componentContext, panelName1, module)));
		const char* panelName2 = "Python Test 2";
		pythonPanel2_.reset(new PythonPanel(createContextObject(componentContext, panelName2, module)));
	}

	bool Finalise(IComponentContext& componentContext) override
	{
		pythonPanel2_.reset();
		pythonPanel1_.reset();
		return true;
	}

	void Unload(IComponentContext& componentContext) override
	{
	}

	std::unique_ptr<PythonPanel> pythonPanel1_;
	std::unique_ptr<PythonPanel> pythonPanel2_;
};

PLG_CALLBACK_FUNC(Python27TestUIPlugin)
} // end namespace wgt
