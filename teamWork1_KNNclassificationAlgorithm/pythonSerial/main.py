import csv
import random
import pandas

# headArray = ["RI", "Na", "Mg", "Al", "Si", "K", "Ca", "Ba", "Fe"]
headArray = ["Pregnancies", "Glucose", "BloodPressure", "SkinThickness"	, "Insulin"	, "BMI"	, "DiabetesPedigreeFunction", "Age"]
headArrayLen = len(headArray)
string_of_reality = "Outcome"
k = 13
reality_set = set()


# 这个函数是求距离的一个函数 传进来的是两个数组 相应位上的数先做减法 再平方后开方
def distance(d1, d2):  # 计算距离的函数
    dis = 0
    for key in headArray:
        dis += (float(d1[key]) - float(d2[key])) ** 2
    return dis**0.5


# 这个函数是将一个测试集(test)的一个元素 和 训练集的所有元素进行距离运算 然后取前k个 通过加权平均后 给出一个可能性
def knn(train_set_copy, test_set_piece_copy, string_of_reality_copy):
    max = -1
    max_str = ""
    flag = False
    # 1. 求距离
    result = [
        {
            "realityData": train_set_copy_piece[string_of_reality_copy],
            "distance": distance(test_set_piece_copy, train_set_copy_piece)
        }
        for train_set_copy_piece in train_set_copy
    ]
    # 2. 排序--升序
    sorted_result = sorted(result, key=lambda item: item["distance"])
    # 3. 取前k个
    k_sorted_result = sorted_result[0:k]
    # 4. 加权平均
    weighting_dic = {}
    # 构造一个 {'1': 0, '2': 0, '3': 0, '5': 0, '6': 0, '7': 0} 这种序列  key是string_of_reality value是数量 用来统计正确率
    for ele in sorted_reality_set:
        weighting_dic[ele] = 0
    sum = 0
    for ele in k_sorted_result:
        sum += ele['distance']

    for ele in k_sorted_result:
        weighting_dic[ele["realityData"]] += 1 - ele['distance']/sum

    for ele_key in weighting_dic.keys():
        if weighting_dic[ele_key] > max:
            max = weighting_dic[ele_key]
            max_str = ele_key
    if max_str == test_set_piece_copy[string_of_reality]:
        str = ",预测正确"
        flag = True
    else:
        str = ",预测错误"
        flag = False
    # print("真实值为：" + test_set_piece_copy[string_of_reality]  + ",预测值为" + max_str  + str)
    return flag


# 读取文件内容
with open("diabetes.csv") as glassClassificationFile:
    straa = glassClassificationFile.readline()
    str_array = straa.split(",")
    reader = csv.DictReader(glassClassificationFile)  # 读入数据
    datas = [row for row in reader]


# 打乱顺序 将开始的数据打乱
random.shuffle(datas)

# 把所有的可能性都放在集合中 不能重复 用python的 set集合就行  比如
for key in datas:
    reality_set.add(key[string_of_reality])
sorted_reality_set = sorted(reality_set)


# 进行分组
dataLen = len(datas)
n = int(2*dataLen/3)
train_set = datas[0:n]
test_set = datas[n:]

judge = True
cnt = 0
test_set_len = len(test_set)
for i in range(0, len(test_set)):
    judge = knn(train_set, test_set[i], string_of_reality)
    if judge:
        cnt = cnt + 1

print("准确率为", cnt/test_set_len * 100)


