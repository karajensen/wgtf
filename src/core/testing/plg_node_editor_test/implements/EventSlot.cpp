#include "EventSlot.h"
#include "core_logging/logging.hpp"

namespace wgt
{
const std::string EVENT_SLOT_LABEL = "event";
const std::string EVENT_SLOT_ICON = "images/greenSlot.png";
const std::string EVENT_SLOT_COLOR = "white";

EventSlot::EventSlot(ObjectHandleT<INode> node, bool isInput)
    : m_label(EVENT_SLOT_LABEL), m_icon(EVENT_SLOT_ICON), m_color(EVENT_SLOT_COLOR), m_editable(true),
      m_isInput(isInput), m_pNode(node)
{
	m_id = reinterpret_cast<size_t>(this);
	connectedSlotsModel.setSource(Collection(m_connectedSlots));
}

std::string EventSlot::Label() const
{
	return m_label;
}

void EventSlot::setLabel(const std::string& label)
{
	m_label = label;
}

std::string EventSlot::Icon() const
{
	return m_icon;
}

std::string EventSlot::Color() const
{
	return m_color;
}

MetaType* EventSlot::Type() const
{
	NGT_ERROR_MSG("METHOD IS NOT IMPLEMENTED\n");
	return nullptr;
}

bool EventSlot::Editable() const
{
	return m_editable;
}

ObjectHandleT<INode> EventSlot::Node() const
{
	return m_pNode;
}

const CollectionModel* EventSlot::GetConnectedSlots() const
{
	return &connectedSlotsModel;
}

bool EventSlot::CanConnect(ObjectHandleT<ISlot> slot)
{
	assert(m_pNode != nullptr);
	return m_pNode->CanConnect(getThis(), slot);
}

bool EventSlot::Connect(size_t connectionID, ObjectHandleT<ISlot> slot)
{
	assert(m_pNode != nullptr);
	bool result = m_pNode->CanConnect(getThis(), slot);

	if (result)
	{
		Collection& collection = connectedSlotsModel.getSource();
		collection.insertValue(collection.size(), slot);
		m_connectionIds.insert(connectionID);
		m_pNode->OnConnect(getThis(), m_connectedSlots.back());
	}

	return result;
}

bool EventSlot::Disconnect(size_t connectionID, ObjectHandleT<ISlot> slot)
{
	assert(m_pNode != nullptr);
	bool result = false;
	auto slotPos =
	std::find_if(m_connectedSlots.begin(), m_connectedSlots.end(),
	             [&slot](const ObjectHandleT<ISlot>& connectedSlot) { return slot->Id() == connectedSlot->Id(); });

	if (slotPos != m_connectedSlots.end())
	{
		result = true;
		m_connectedSlots.erase(slotPos);
		m_connectionIds.erase(connectionID);
		m_pNode->OnDisconnect(getThis(), slot);
	}

	return result;
}
} // end namespace wgt
