#include "core_generic_plugin/interfaces/i_application.hpp"

#include "core_common/assert.hpp"
#include "core_generic_plugin/generic_plugin.hpp"
#include "core_dependency_system/i_interface.hpp"
#include "core_logging/logging.hpp"

#include <chrono>
#include <thread>

namespace wgt
{
class TimeoutTestPluginApplication : public Implements<IApplication>
{
public:
	int startApplication() override
	{
		int i = 0;
		while (true)
		{
			NGT_TRACE_MSG("%d seconds\n", i);
			std::this_thread::sleep_for(std::chrono::seconds(1));
			++i;
		}
		return 0;
	}

	void quitApplication() override
	{
	}

	TimerId startTimer(int, TimerCallback) override
	{
		TF_ASSERT(!"This assert is meant to fail");
		return 0;
	}

	void killTimer(TimerId)
	{
		TF_ASSERT(!"This assert is meant to fail");
	}

	void setAppSettingsName(const char* appName) override
	{
		assert(!"This assert is meant to fail");
	}

	const char* getAppSettingsName() override
	{
		assert(!"This assert is meant to fail");
		static const char name = '\0';
		return name;
	}
};

/**
 *	A plugin which has an infinite loop on purpose to check if it is detected
 *	by the automated testing framework.
 *
 * @ingroup plugins
 */
class TimeoutTestPluginTestPlugin : public PluginMain
{
public:
	TimeoutTestPluginTestPlugin(IComponentContext& contextManager)
	{
	}

	bool PostLoad(IComponentContext& contextManager) override
	{
		contextManager.registerInterface(new TimeoutTestPluginApplication());
		return true;
	}
};

PLG_CALLBACK_FUNC(TimeoutTestPluginTestPlugin)

} // end namespace wgt
