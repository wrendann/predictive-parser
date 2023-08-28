import csv

def read_files():
    grammar = {}
    first = {}
    follow = {}
    with open('grammarLL.txt', 'r') as file:
      lines = file.readlines()
      for line in lines:
          lhs, rhs = line.strip().split('->')
          rhs_symbols = rhs.strip().split()
          lhs = lhs.strip()
          if lhs not in grammar.keys():
             grammar[lhs] = []
          grammar[lhs].append(rhs_symbols)

    with open('First-Follow.txt', 'r') as file:
       lines = file.readlines()
       index_of_follow = lines.index('FOLLOW\n')
       first_lines = lines[1:index_of_follow]
       follow_lines = lines[index_of_follow+1:]
       for line in first_lines:
          lhs, rhs = line.strip().split(':')
          rhs_symbols = rhs.strip().split()
          lhs = lhs.strip()
          first[lhs] = rhs_symbols
       for line in follow_lines:
          lhs, rhs = line.strip().split(':')
          rhs_symbols = rhs.strip().split()
          lhs = lhs.strip()
          follow[lhs] = rhs_symbols

    return grammar, first, follow

def find_first(lst, first):
   res = set()
   if lst[0] in first:
      res.update(first[lst[0]])
   else:
      res.add(lst[0])
   i = 1
   while(i < len(lst) and 'ε' in res):
      res.remove('ε')
      if lst[i] in first:
         res.update(first[lst[i]])
      else:
         res.add(lst[i])
   return res

def get_terminals_and_non_terminals(grammar):
   non_terminals = set()
   symbols = set()
   for lhs, rhses in grammar.items():
      non_terminals.add(lhs)
      for rhs in rhses:
         symbols.update(rhs)
   terminals = symbols - non_terminals
   return terminals, non_terminals

def generate_parsing_table(grammar, first, follow):
   M = {}
   for lhs, rhses in grammar.items():
      for rhs in rhses:
        first_symbols = find_first(rhs, first)
        if 'ε' in first_symbols:
          first_symbols.remove('ε')
          first_symbols.update(follow[lhs])
        if lhs not in M:
          M[lhs] = {}
        for b in first_symbols:
           M[lhs][b] = rhs         
   return M

def make_into_array(M, grammar):
   terminals, non_terminals = get_terminals_and_non_terminals(grammar)
   terminals.add('$')
   res = []
   row = ['']
   for b in terminals:
      row.append(b)
   res.append(row)
   row = []
   for A in non_terminals:
      row.append(A)
      for b in terminals:
         if A in M.keys() and b in M[A].keys():
            row.append(' '.join(M[A][b]))
         else:
            row.append('')
      res.append(row)
      row = []
   return res


def main():
   grammar, first, follow = read_files()
   parsing_table = generate_parsing_table(grammar, first, follow)
   res_array = make_into_array(parsing_table, grammar)
   print(res_array)

   csv_file_path = 'parsing-table.csv'
   with open(csv_file_path, mode='w', newline='') as csv_file:
      csv_writer = csv.writer(csv_file)
      for row in res_array:
         csv_writer.writerow(row)

if __name__ == "__main__":
    main()
