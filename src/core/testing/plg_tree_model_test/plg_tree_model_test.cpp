#include "core_dependency_system/i_interface.hpp"
#include "core_dependency_system/depends.hpp"
#include "core_data_model/abstract_item_model.hpp"
#include "core_generic_plugin/interfaces/i_application.hpp"
#include "core_generic_plugin/generic_plugin.hpp"
#include "core_logging/logging.hpp"
#include "core_ui_framework/i_ui_application.hpp"
#include "core_ui_framework/i_ui_framework.hpp"
#include "core_ui_framework/i_view.hpp"
#include "core_ui_framework/interfaces/i_view_creator.hpp"
#include "testing/data_model_test/test_tree_model.hpp"

#include <vector>
#include <future>

WGT_INIT_QRC_RESOURCE

namespace wgt
{
/**
* A plugin which creates various styles of trees with sample data
*
* @ingroup plugins
* @image html plg_tree_model_test.png
* @note Requires Plugins:
*       - @ref coreplugins
*/
class TreeModelTestPlugin : public PluginMain, Depends<IViewCreator, IUIFramework>
{
private:
	InterfacePtrs types_;
	wg_future<std::unique_ptr<IView>> treeView_;
	std::shared_ptr<AbstractTreeModel> treeModel_;

public:
	//==========================================================================
	TreeModelTestPlugin(IComponentContext& contextManager)
	{
	}

	//==========================================================================
	bool PostLoad(IComponentContext& contextManager)
	{
		return true;
	}

	//==========================================================================
	void Initialise(IComponentContext& contextManager)
	{
		treeModel_ = std::make_shared<TestTreeModel>();
		auto viewCreator = get<IViewCreator>();

		if (viewCreator)
		{
			treeView_ = viewCreator->createView("plg_tree_model_test/test_tree_panel.qml", treeModel_);
		}
	}
	//==========================================================================
	bool Finalise(IComponentContext& contextManager)
	{
		auto uiApplication = contextManager.queryInterface<IUIApplication>();
		assert(uiApplication != nullptr);

		if (treeView_.valid())
		{
			auto view = treeView_.get();
			uiApplication->removeView(*view);
			view = nullptr;
		}

		treeModel_ = nullptr;
		return true;
	}
	//==========================================================================
	void Unload(IComponentContext& contextManager)
	{
		for (auto type : types_)
		{
			contextManager.deregisterInterface(type.get());
		}
	}
};

PLG_CALLBACK_FUNC(TreeModelTestPlugin)
} // end namespace wgt
