#include "alert_models.hpp"

#include "core_common/assert.hpp"
#include "core_generic_plugin/interfaces/i_component_context.hpp"
#include "core_logging_system/interfaces/i_logging_system.hpp"
#include "core_logging_system/log_level.hpp"
#include "metadata/alert_models.mpp"
#include "popup_alert_presenter.hpp"
#include "core_reflection/type_class_definition.hpp"
#include "core_reflection/i_definition_manager.hpp"
#include "core_ui_framework/i_action.hpp"
#include "core_ui_framework/i_ui_application.hpp"
#include "core_ui_framework/i_ui_framework.hpp"

namespace wgt
{
PopupAlertPresenter::PopupAlertPresenter(IComponentContext& contextManager)
    : contextManager_(&contextManager), alertCounter_(0)
{
	// Setup the alert page model
	auto definitionManager = contextManager.queryInterface<IDefinitionManager>();
	TF_ASSERT(definitionManager != nullptr);

	alertPageModel_ = ManagedObject<AlertPageModel>::make();
	TF_ASSERT(alertPageModel_ != nullptr);

	// Setup the display via QML with the model as input
	auto uiApplication = contextManager.queryInterface<IUIApplication>();
	TF_ASSERT(uiApplication != nullptr);

	IUIFramework* qtFramework = contextManager.queryInterface<IUIFramework>();
	TF_ASSERT(qtFramework != nullptr);

	auto viewCreator = get<IViewCreator>();
	if (viewCreator)
	{
		alertWindow_ = viewCreator->createView("plg_alert_ui/alert_window.qml", alertPageModel_.getHandleT());
	}

	ILoggingSystem* loggingSystem = contextManager.queryInterface<ILoggingSystem>();
	if (loggingSystem != nullptr)
	{
		AlertManager* alertManager = loggingSystem->getAlertManager();
		if (alertManager != nullptr)
		{
			auto uiApplication = contextManager.queryInterface<IUIApplication>();
			if (nullptr != uiApplication)
			{
				using namespace std::placeholders;
				testAddAlert_ =
				qtFramework->createAction("AddTestAlert", std::bind(&PopupAlertPresenter::addTestAlert, this, _1));
				uiApplication->addAction(*testAddAlert_);
			}
		}
	}
}

PopupAlertPresenter::~PopupAlertPresenter()
{
	TF_ASSERT(contextManager_ != nullptr);
	auto uiApplication = contextManager_->queryInterface<IUIApplication>();
	if (uiApplication != nullptr)
	{
		uiApplication->removeAction(*testAddAlert_);
		if (alertWindow_.valid())
		{
			auto view = alertWindow_.get();
			uiApplication->removeView(*view);
			view = nullptr;
		}
	}
	testAddAlert_.reset();
}

void PopupAlertPresenter::show(const char* text)
{
	alertPageModel_->addAlert(text);
}

void PopupAlertPresenter::addTestAlert(IAction* action)
{
	ILoggingSystem* loggingSystem = contextManager_->queryInterface<ILoggingSystem>();
	if (loggingSystem != nullptr)
	{
		AlertManager* alertManager = loggingSystem->getAlertManager();
		if (alertManager != nullptr)
		{
			loggingSystem->log(LOG_ALERT, "This is test alert #%d", alertCounter_++);
		}
	}
}
} // end namespace wgt
