#include "gtest/gtest.h"

#include "geometry.h"
#include "kdtree.h"

using Point = geometry::Point<double, 3>;
using QueryResult = kdtree::QueryResult;
using KDTree = kdtree::kdtree<double, Point>;
using TreeData = std::initializer_list<std::initializer_list<double>>;

QueryResult query_tree(TreeData data, Point query) {
    KDTree tree {};
    for (std::vector<double> d : data) {
        tree.add({d[0], d[1], d[2]}, d[3]);
    }
    tree.build();
    return tree.nearest_iterative(query);
}

TEST(KdtreeTest, SinglePointTest) {
    double value {5.0};
    const TreeData tree_data {
        {0, 0, 0, value},
    };
    QueryResult result;

    result = query_tree(tree_data, {0, 0, 0});
    EXPECT_DOUBLE_EQ(0, result.distance);
    EXPECT_DOUBLE_EQ(value, result.value);

    result = query_tree(tree_data, {0, 0, 10});
    EXPECT_DOUBLE_EQ(100, result.distance);
    EXPECT_DOUBLE_EQ(value, result.value);

    result = query_tree(tree_data, {0, 0, -10});
    EXPECT_DOUBLE_EQ(100, result.distance);
    EXPECT_DOUBLE_EQ(value, result.value);
}

TEST(KdtreeTest, TwoPointTest) {
    double value1 {7.0};
    double value2 {5.0};
    const TreeData tree_data {
        {0, 0, 0, value1},
        {0, 0, 10, value2},
    };
    QueryResult result;
    result = query_tree(tree_data, {0, 0, 10});
    EXPECT_DOUBLE_EQ(0, result.distance);
    EXPECT_DOUBLE_EQ(value2, result.value);

    result = query_tree(tree_data, {-10, 0, 0});
    EXPECT_DOUBLE_EQ(100, result.distance);
    EXPECT_DOUBLE_EQ(value1, result.value);

    result = query_tree(tree_data, {0, 0, 0});
    EXPECT_DOUBLE_EQ(0, result.distance);
    EXPECT_DOUBLE_EQ(value1, result.value);

    result = query_tree(tree_data, {0, 0, 4});
    EXPECT_DOUBLE_EQ(16, result.distance);
    EXPECT_DOUBLE_EQ(value1, result.value);

    result = query_tree(tree_data, {0, 0, 6});
    EXPECT_DOUBLE_EQ(16, result.distance);
    EXPECT_DOUBLE_EQ(value2, result.value);
}


TEST(KdtreeTest, TestMiddlePoint) {
    double value1 {7.0};
    double value2 {5.0};
    double mean_value = (value1 + value2)/2.0;
    const TreeData tree_data {
        {0, 0, 0, value1},
        {0, 0, 10, value2},
    };
    QueryResult result;

    result = query_tree(tree_data, {0, 0, 5.0000});
    EXPECT_DOUBLE_EQ(25, result.distance);
    EXPECT_DOUBLE_EQ(mean_value , result.value);

    result = query_tree(tree_data, {-100, 100, 5.0000});
    EXPECT_DOUBLE_EQ(mean_value , result.value);

    result = query_tree(tree_data, {-100, 0, 5.0000});
    EXPECT_DOUBLE_EQ(mean_value , result.value);
}


TEST(KdtreeTest, TestCube) {
    double value000 {1};
    double value100 {2};
    double value010 {3};
    double value001 {4};
    double value110 {5};
    double value011 {6};
    double value101 {7};
    double value111 {8};

    const TreeData tree_data {
        {0, 0, 0, value000},
        {1, 0, 0, value100},
        {0, 1, 0, value010},
        {0, 0, 1, value001},
        {1, 1, 0, value110},
        {0, 1, 1, value011},
        {1, 0, 1, value101},
        {1, 1, 1, value111},
    };

    EXPECT_DOUBLE_EQ(query_tree(tree_data, {0, 0, 0}).value , value000);
    EXPECT_DOUBLE_EQ(query_tree(tree_data, {1, 1, 1}).value , value111);

    double bump = 0.000000000001;
    for (std::vector<double> d : tree_data) {
        EXPECT_DOUBLE_EQ(query_tree(tree_data, {
            0.5 + (d[0] == 0 ? -bump : bump),
            0.5 + (d[1] == 0 ? -bump : bump),
            0.5 + (d[2] == 0 ? -bump : bump)
        }).value , d[3]);
    }

    double average_of_all_values = 4.5;
    EXPECT_DOUBLE_EQ(query_tree(tree_data, {0.5, 0.5, 0.5}).value, average_of_all_values);
}
