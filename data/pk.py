if __name__ == '__main__':
	i = 1
	fout = open('county.csv', 'w')
	with open('countyTable.csv', 'r') as fin:
		for line in fin:
			fout.write(str(i) + ',' + line)
			i = i + 1
	fout.close()