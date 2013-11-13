#!/bin/python

'''
Quick script for adding primary key field to county rows
because django doesn't support multi-column primary keys
@author Peggy
'''

if __name__ == '__main__':
	i = 1
	fout = open('county.csv', 'w')
	with open('countyTable.csv', 'r') as fin:
		for line in fin:
			fout.write(str(i) + ',' + line)
			i = i + 1
	fout.close()
