#include "move_item_data_command.hpp"
#include "move_item_data_command_arg.hpp"

#include "core_command_system/i_command_manager.hpp"
#include "core_data_model/abstract_item_model.hpp"
#include "core_reflection/i_definition_manager.hpp"
#include "core_reflection/generic/generic_object.hpp"
#include "core_reflection/metadata/meta_utilities.hpp"
#include "core_reflection/metadata/meta_impl.hpp"
#include "core_variant/variant.hpp"
#include "core_object/managed_object.hpp"

namespace wgt
{
namespace MoveItemDataCommand_Detail
{
bool isValid(const MoveItemDataCommandArgument* pCommandArgs)
{
	if (pCommandArgs == nullptr)
	{
		return false;
	}

	if (pCommandArgs->pModel_ == nullptr)
	{
		return false;
	}

	if (pCommandArgs->startPos_ < 0)
	{
		return false;
	}

	if (pCommandArgs->count_ < 0)
	{
		return false;
	}

	if (pCommandArgs->endPos_ < 0)
	{
		return false;
	}

	if (pCommandArgs->startParent_ == pCommandArgs->endParent_ && pCommandArgs->endPos_ >= pCommandArgs->startPos_ &&
	    pCommandArgs->endPos_ <= pCommandArgs->startPos_ + pCommandArgs->count_)
	{
		return false;
	}

	return true;
}
} // end namespace MoveItemDataCommand_Detail

MoveItemDataCommand::~MoveItemDataCommand()
{
}

bool MoveItemDataCommand::customUndo() const /* override */
{
	return true;
}

bool MoveItemDataCommand::canUndo(const ObjectHandle& arguments) const /* override */
{
	return this->validateArguments(arguments);
}

bool MoveItemDataCommand::undo(const ObjectHandle& arguments) const /* override */
{
	if (!arguments.isValid())
	{
		return false;
	}

	auto pCommandArgs = arguments.getBase<MoveItemDataCommandArgument>();
	if (!MoveItemDataCommand_Detail::isValid(pCommandArgs))
	{
		return false;
	}

	auto& model = (*pCommandArgs->pModel_);

	const auto& dir = (pCommandArgs->direction_);
	const auto& startParent = (pCommandArgs->startParent_);
	const auto& endParent = (pCommandArgs->endParent_);

	auto startPos = (pCommandArgs->startPos_);
	auto endPos = (pCommandArgs->endPos_);
	auto count = (pCommandArgs->count_);

	if (startParent == endParent)
	{
		if (endPos > startPos)
		{
			endPos--;
		}
		else
		{
			startPos++;
		}
	}

	if (dir == MoveItemDataCommandArgument::Direction::ROW)
	{
		return model.moveRows(endParent, endPos, count, startParent, startPos);
	}

	return false;
}

bool MoveItemDataCommand::redo(const ObjectHandle& arguments) const /* override */
{
	if (!arguments.isValid())
	{
		return false;
	}

	auto pCommandArgs = arguments.getBase<MoveItemDataCommandArgument>();
	if (!MoveItemDataCommand_Detail::isValid(pCommandArgs))
	{
		return false;
	}

	const auto& dir = (pCommandArgs->direction_);
	auto& model = (*pCommandArgs->pModel_);

	const auto& startPos = (pCommandArgs->startPos_);
	const auto& endPos = (pCommandArgs->endPos_);
	const auto& count = (pCommandArgs->count_);

	const auto& startParent = (pCommandArgs->startParent_);
	const auto& endParent = (pCommandArgs->endParent_);

	if (dir == MoveItemDataCommandArgument::Direction::ROW)
	{
		return model.moveRows(startParent, startPos, count, endParent, endPos);
	}

	return false;
}

CommandDescription MoveItemDataCommand::getCommandDescription(const ObjectHandle& arguments) const /* override */
{
    auto object = GenericObject::create();

	if (!arguments.isValid())
	{
		object->set("Name", "Invalid");
		object->set("Type", "Move");
	}
    else
    {
        auto pCommandArgs = arguments.getBase<MoveItemDataCommandArgument>();
        if (!MoveItemDataCommand_Detail::isValid(pCommandArgs))
        {
            object->set("Name", "Invalid");
            object->set("Type", "Move");
        }
        else
        {
            object->set("Name", "Move");
            object->set("Type", "Move");
        }
    }

    return std::move(object);
}

const char* MoveItemDataCommand::getId() const /* override */
{
	static const char* s_Id = wgt::getClassIdentifier<MoveItemDataCommand>();
	return s_Id;
}

bool MoveItemDataCommand::validateArguments(const ObjectHandle& arguments) const /* override */
{
	const auto pCommandArgs = arguments.getBase<MoveItemDataCommandArgument>();
	return MoveItemDataCommand_Detail::isValid(pCommandArgs);
}

Variant MoveItemDataCommand::execute(const ObjectHandle& arguments) const /* override */
{
	auto pCommandArgs = arguments.getBase<MoveItemDataCommandArgument>();
	if (!MoveItemDataCommand_Detail::isValid(pCommandArgs))
	{
		return CommandErrorCode::INVALID_ARGUMENTS;
	}

	const auto& dir = (pCommandArgs->direction_);
	auto& model = (*pCommandArgs->pModel_);

	const auto& startPos = (pCommandArgs->startPos_);
	const auto& endPos = (pCommandArgs->endPos_);
	const auto& count = (pCommandArgs->count_);

	const auto& startParent = (pCommandArgs->startParent_);
	const auto& endParent = (pCommandArgs->endParent_);

	auto result = false;

	if (dir == MoveItemDataCommandArgument::Direction::ROW)
	{
		result = model.moveRows(startParent, startPos, count, endParent, endPos);
	}

	const auto errorCode = result ? CommandErrorCode::COMMAND_NO_ERROR : CommandErrorCode::FAILED;
	return errorCode;
}

CommandThreadAffinity MoveItemDataCommand::threadAffinity() const /* override */
{
	return CommandThreadAffinity::UI_THREAD;
}

ManagedObjectPtr MoveItemDataCommand::copyArguments(const ObjectHandle& arguments) const
{
	return Command::copyArguments<MoveItemDataCommandArgument>(arguments);
}
} // end namespace wgt
