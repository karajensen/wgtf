#ifndef CHILD_LIST_ADAPTER_HPP
#define CHILD_LIST_ADAPTER_HPP

#include "i_list_adapter.hpp"
#include "core_qt_common/qt_new_handler.hpp"

namespace wgt
{
class ChildListAdapter : public IListAdapter
{
	Q_OBJECT

	DECLARE_QT_MEMORY_HANDLER

public:
	ChildListAdapter(const QModelIndex& parent, bool connect = true);
	virtual ~ChildListAdapter();

	QAbstractItemModel* model() const override;

	QModelIndex adaptedIndex(int row, int column, const QModelIndex& parent) const override;
	int rowCount(const QModelIndex& parent) const override;

	void onParentDataChanged(const QModelIndex& topLeft, const QModelIndex& bottomRight,
	                         const QVector<int>& roles) override;
	void onParentLayoutAboutToBeChanged(const QList<QPersistentModelIndex>& parents,
	                                    QAbstractItemModel::LayoutChangeHint hint) override;
	void onParentLayoutChanged(const QList<QPersistentModelIndex>& parents,
	                           QAbstractItemModel::LayoutChangeHint hint) override;
	void onParentRowsAboutToBeInserted(const QModelIndex& parent, int first, int last) override;
	void onParentRowsInserted(const QModelIndex& parent, int first, int last) override;
	void onParentRowsAboutToBeRemoved(const QModelIndex& parent, int first, int last) override;
	void onParentRowsRemoved(const QModelIndex& parent, int first, int last) override;
	virtual void onParentRowsAboutToBeMoved(const QModelIndex& sourceParent, int sourceFirst, int sourceLast,
	                                        const QModelIndex& destinationParent, int destinationRow) override;
	virtual void onParentRowsMoved(const QModelIndex& sourceParent, int sourceFirst, int sourceLast,
	                               const QModelIndex& destinationParent, int destinationRow) override;

private:
	QPersistentModelIndex parent_;
	QModelIndex removedParent_;
	bool connect_;
};
} // end namespace wgt
#endif // CHILD_LIST_ADAPTER_HPP
