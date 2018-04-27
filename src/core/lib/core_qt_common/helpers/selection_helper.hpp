#ifndef SELECTION_HELPER_HPP
#define SELECTION_HELPER_HPP

#include <QObject>
#include <QModelIndex>
#include <QVariant>
#include "core_qt_common/qt_new_handler.hpp"
#include "core_dependency_system/depends.hpp"
#include "core_qt_common/interfaces/i_qt_helpers.hpp"

namespace wgt
{
class ISelectionHandler;

// TODO: NGT-849
// Eventually, we need to remove this class
class SelectionHelper : public QObject, Depends<IQtHelpers>
{
	Q_OBJECT

	Q_PROPERTY(QVariant source READ getSource WRITE setSource NOTIFY sourceChanged)

	DECLARE_QT_MEMORY_HANDLER
public:
	typedef ISelectionHandler SourceType;

	SelectionHelper(QObject* parent = nullptr);
	~SelectionHelper();

	void source(SourceType* selectionSource);
	const SourceType* source() const;

	Q_INVOKABLE void select(const QModelIndexList& selectionList);

private:
	QVariant getSource() const;
	bool setSource(const QVariant& source);

signals:
	void sourceChanged();

private:
	SourceType* source_;
	std::vector<QModelIndex> selectionSet_;
};
} // end namespace wgt
#endif // SELECTION_HELPER_HPP
