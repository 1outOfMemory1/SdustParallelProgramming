import csv
import random
import time

# 全局变量

headerArray = []  # 这个是第一行的除去第二个 headerArray = ["RI", "Na", "Mg", "Al", "Si", "K", "Ca", "Ba", "Fe"]
headerArrayLen = len(headerArray)  # 获取headerArray 的 length
string_of_reality = ""  # 这个是需要预测的列的名字
k = 14      # 用来设置取前 k 个距离最近的数据
reality_set = set()  # 这个是用来存储结果可能的所有种类 比如预测是否得病只有 两种可能 得病和不得病


# 这个函数是求距离的一个函数 传进来的是两个数组 相应位上的数先做减法 再平方后开方
def distance(d1, d2):  # 计算距离的函数
    dis = 0
    for ele in headerArray:
        dis += (float(d1[ele]) - float(d2[ele])) ** 2
    return dis**0.5


# 这个函数是将一个测试集(test)的一个元素 和 训练集的所有元素进行距离运算 然后取前k个 通过加权平均后 给出一个可能性
def knn(train_set_copy, test_set_piece_copy, string_of_reality_copy):
    max_weight = -1   # 用来存储最大权重
    max_str = ""  # 用来存储最大权重的字符串  也就是预测值
    flag = False  # 返回给主函数 用于判断预测是否正确
    weighting_dic = {}
    sum = 0
    # 构造一个 {'1': 0, '2': 0, '3': 0, '5': 0, '6': 0, '7': 0} 这种序列  key是string_of_reality value是数量 用来统计正确率
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
    for ele in sorted_reality_set:   # 权值全部设置为 0
        weighting_dic[ele] = 0
    for ele in k_sorted_result:  # 计算一下前k个点 距离测试点的总距离 用来后边算权值
        sum += ele['distance']
    for ele in k_sorted_result: # 这个算法目的在于综合考虑所有前k个距离测试点最近的元素的影响
        # 其实也可以统计一下出现概率最高的
        weighting_dic[ele["realityData"]] += 1 - ele['distance']/sum

    for ele_key in weighting_dic.keys():  # 遍历找到权值最大的 然后将它设置为预测值
        if weighting_dic[ele_key] > max_weight:
            max_weight = weighting_dic[ele_key]
            max_str = ele_key
    if max_str == test_set_piece_copy[string_of_reality]:
        str = ",预测正确"
        flag = True
    else:
        str = ",预测错误"
        flag = False
    # print("真实值为：" + test_set_piece_copy[string_of_reality]  + ",预测值为" + max_str  + str)
    return flag  # 返回预测是否正确 用于统计正确率


#  主程序
# 读取文件内容

starttime = time.time()
fileName = "glass.csv"

print("读取文件为: " + fileName)
with open(fileName) as file:
    # straa = glassClassificationFile.readline()
    # str_array = straa.split(",")
    # print(str_array)
    reader = csv.DictReader(file)  # 读入数据
    datas = [row for row in reader]  # 构造字典数组 每一行都是一个小字典
    piece = datas[0]  # 拿出第一行数据 {'Pregnancies': '6', 'Glucose': '148', 'BloodPressure': '72',
    # 'SkinThickness': '35', 'Insulin': '0', 'BMI': '33.6', 'DiabetesPedigreeFunction': '0.627',
    # 'Age': '50', 'Outcome': '1'} 类似数据 是这样 这个数据是用来预测肥胖概率的  最终Outcome为0 就表示不肥胖 前边的8个数据 是用来做距离运算的
    # print(piece)
    for a in piece.keys():  # 把piece （第一行数据）的 key 遍历添加到一个数组中去
        headerArray.append(a)
    string_of_reality = headerArray.pop()  # 将最后一个要预测的值 从数组中删除然后进行存储 后边要用

    # for aa in datas:
    #     print(aa)


# 打乱顺序 将开始的数据打乱
random.shuffle(datas)

# 把所有的可能性都放在集合中 不能重复 用python的 set集合就行  比如
for key in datas:
    reality_set.add(key[string_of_reality])
sorted_reality_set = sorted(reality_set)


# 进行分组
dataLen = len(datas)
n = int(2*dataLen/3)  # 2/3 用于训练集 1/3 用于测试集
train_set = datas[0:n] # 2/3 用于训练集 1/3 用于测试集
test_set = datas[n:] # 2/3 用于训练集 1/3 用于测试集

judge = True  # 用于接受knn函数返回的结果 如果是true 说明预测正确  否则就是预测错误
cnt = 0  # cnt 用于统计正确的数量
test_set_len = len(test_set)
for i in range(0, len(test_set)):
    judge = knn(train_set, test_set[i], string_of_reality)
    if judge:
        cnt = cnt + 1
print("根据以下参数来预测结果(列的名称) ：", headerArray)
print("结果所在的列名称是：" + string_of_reality, "   他的种类有：", sorted_reality_set)
print("准确率为", cnt/test_set_len * 100)
endtime = time.time()
dtime = endtime - starttime

print("程序运行时间：%.8s s" % dtime)  #显示到微秒
