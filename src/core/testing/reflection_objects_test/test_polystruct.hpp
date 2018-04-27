#ifndef TEST_POLYSTRUCTURE_HPP
#define TEST_POLYSTRUCTURE_HPP

#include "core_reflection/reflected_object.hpp"
#include "core_dependency_system/depends.hpp"
#include "test_structure.hpp"
#include "test_macros.hpp"
#include <vector>

namespace wgt
{
class IDefinitionManager;

class TestPolyStruct : protected Depends<IDefinitionManager>
{
	DECLARE_REFLECTED

public:
    TestPolyStruct();

private:
	DEFINE_TEST_DATA_TYPES()
	TestInheritedStruct structure_;
};

class TestInheritedPolyStruct : public TestPolyStruct
{
	DECLARE_REFLECTED

public:
	TestInheritedPolyStruct();

private:
	DEFINE_INHERITS_TEST_DATA_TYPES()
};
} // end namespace wgt
#endif // TEST_POLYSTRUCTURE_HPP
