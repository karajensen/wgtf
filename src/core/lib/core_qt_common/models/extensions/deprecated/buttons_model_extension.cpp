#include "buttons_model_extension.hpp"

#include "core_common/assert.hpp"
#include "core_qt_common/interfaces/i_qt_helpers.hpp"
#include "core_data_model/i_item.hpp"

namespace wgt
{
QHash<int, QByteArray> ButtonsModelExtension::roleNames() const
{
	QHash<int, QByteArray> roles;
	registerRole(buttonIconRole::roleName_, roles);
	registerRole(buttonEnabledRole::roleName_, roles);
	registerRole(buttonClickedRole::roleName_, roles);
	return roles;
}

QVariant ButtonsModelExtension::data(const QModelIndex& index, int role) const
{
	ItemRole::Id roleId;
	if (!decodeRole(role, roleId))
	{
		return QVariant();
	}

	TF_ASSERT(index.isValid());
	IItem* item = reinterpret_cast<IItem*>(index.internalPointer());
	if (item == nullptr)
	{
		return QVariant();
	}

	ItemRole::Id supportedRoles[] = { buttonIconRole::roleId_, buttonEnabledRole::roleId_, buttonClickedRole::roleId_ };

	if (std::find(std::begin(supportedRoles), std::end(supportedRoles), roleId) != std::end(supportedRoles))
	{
		return get<IQtHelpers>()->toQVariant(item->getData(index.column(), roleId), nullptr);
	}

	return QVariant();
}

bool ButtonsModelExtension::setData(const QModelIndex& index, const QVariant& value, int role)
{
	ItemRole::Id roleId;
	if (!decodeRole(role, roleId))
	{
		return false;
	}

	TF_ASSERT(index.isValid());
	IItem* item = reinterpret_cast<IItem*>(index.internalPointer());
	if (item == nullptr)
	{
		return false;
	}

	ItemRole::Id supportedRoles[] = { buttonIconRole::roleId_, buttonEnabledRole::roleId_, buttonClickedRole::roleId_ };

	if (std::find(std::begin(supportedRoles), std::end(supportedRoles), roleId) != std::end(supportedRoles))
	{
		return item->setData(index.column(), roleId, get<IQtHelpers>()->toVariant(value));
	}

	return false;
}

} // namespace wgt
