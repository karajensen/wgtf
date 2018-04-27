#include "test_model.hpp"
#include "core_data_model/i_item_role.hpp"
#include <vector>
#include "wg_types/vector3.hpp"

namespace wgt
{
ITEMROLE(name)
ITEMROLE(description)
ITEMROLE(number)

class ListDataModelItem : public AbstractListItem
{
public:
	ListDataModelItem(const char* name, const char* description, int index)
	    : name_(name), description_(description), index_(index)
	{
	}

	Variant getData(int column, ItemRole::Id roleId) const override
	{
		if (roleId == ItemRole::nameId)
		{
			return name_;
		}
		else if (roleId == ItemRole::descriptionId)
		{
			return description_;
		}
		else if (roleId == ItemRole::numberId)
		{
			return index_;
		}
		return Variant();
	}

	bool setData(int column, ItemRole::Id roleId, const Variant& data) override
	{
		return false;
	}
	std::string name_;
	std::string description_;
	int index_;
};

namespace ListDataModelDetails
{
static const std::string s_RolesArr[] = { ItemRole::nameName, ItemRole::descriptionName, ItemRole::numberName };

static const std::vector<std::string> s_RolesVec(&s_RolesArr[0],
                                                 &s_RolesArr[0] + std::extent<decltype(s_RolesArr)>::value);

}; // end namespace ListDataModelDetails

struct ListDataModel::Impl
{
	Impl()
	{
	}
	void init(int count)
	{
		std::string name;
		std::string desc = "Test Object";
		for (int i = 0; i < count; i++)
		{
			name = "Object[" + std::to_string(i + 1) + "]";
			items_.emplace_back(new ListDataModelItem(name.c_str(), desc.c_str(), i));
		}
	}
	std::vector<std::unique_ptr<ListDataModelItem>> items_;
};

ListDataModel::ListDataModel() : impl_(new Impl())
{
}

ListDataModel::~ListDataModel()
{
}

void ListDataModel::init(int count)
{
	impl_->init(count);
}

AbstractItem* ListDataModel::item(int row) const
{
	assert(row < static_cast<int>(impl_->items_.size()) && row >= 0);
	return impl_->items_[row].get();
}

int ListDataModel::index(const AbstractItem* item) const
{
	auto it = std::find_if(
	impl_->items_.begin(), impl_->items_.end(),
	[&](const std::unique_ptr<ListDataModelItem>& listDataModelItem) { return listDataModelItem.get() == item; });
	if (it == impl_->items_.end())
	{
		assert(false);
		return -1;
	}
	return static_cast<int>(it - impl_->items_.begin());
}

int ListDataModel::rowCount() const
{
	return static_cast<int>(impl_->items_.size());
}

int ListDataModel::columnCount() const
{
	return 1;
}

//------------------------------------------------------------------------------
void ListDataModel::iterateRoles(const std::function<void(const char*)>& iterFunc) const
{
	for (auto&& role : ListDataModelDetails::s_RolesVec)
	{
		iterFunc(role.c_str());
	}
}

//------------------------------------------------------------------------------
std::vector<std::string> ListDataModel::roles() const
{
	return ListDataModelDetails::s_RolesVec;
}

} // end namespace wgt
