#include "script_qt_type_converter.hpp"

#include "qt_scripting_engine_base.hpp"
#include "qt_script_object.hpp"
#include "core_reflection/object_handle.hpp"

namespace wgt
{
ScriptQtTypeConverter::ScriptQtTypeConverter(QtScriptingEngineBase& scriptingEngine)
    : IQtTypeConverter(), scriptingEngine_(scriptingEngine)
{
}

bool ScriptQtTypeConverter::toVariant(const QVariant& qVariant, Variant& o_variant) const
{
	if (!qVariant.canConvert<QObject*>())
	{
		return false;
	}

	auto object = qVariant.value<QObject*>();
	auto scriptObject = dynamic_cast<QtScriptObject*>(object);
	if (scriptObject == nullptr)
	{
		return false;
	}

	o_variant = scriptObject->object();
	return true;
}

bool ScriptQtTypeConverter::toQVariant(const Variant& variant, QVariant& o_qVariant, QObject* parent) const
{
    auto scriptObject = scriptingEngine_.createScriptObject(variant, parent);
    if (scriptObject != nullptr)
    {
        o_qVariant = QVariant::fromValue<QtScriptObject*>(scriptObject);
        return true;
    }
    return false;
}

bool ScriptQtTypeConverter::toQVariant(const ObjectHandle& object, QVariant& o_qVariant, QObject* parent) const
{
	if (!object.isValid())
	{
		o_qVariant = QVariant::Invalid;
		return true;
	}
    return toQVariant(Variant(object), o_qVariant, parent);
}
} // end namespace wgt
