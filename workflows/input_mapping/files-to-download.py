import os
import sys
import json

DIR=os.path.dirname(os.path.realpath(__file__))
with open(DIR + '/input_mapping.json') as f:
  data=json.load(f)

for file in data[sys.argv[1]][sys.argv[2]]:
  print(file)
