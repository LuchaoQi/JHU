import matplotlib.pyplot as plt

f = open('3c.txt','r')
dic = {}
for lines in f:
	line =  lines.strip().rstrip('\n').split('\t')
	a = int(line[0])//1000 + 1
	if a in dic:
		dic[a] = dic[a] + int(line[1])
	else:
		dic[a] = int(line[1])
for i in dic:
	dic[i] = dic[i]/1000

f.close()

plt.scatter(dic.keys(),dic.values())
plt.xlabel('bin #')
plt.ylabel('MAPQ')
plt.show()
