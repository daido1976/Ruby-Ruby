require './minruby'
require 'pry'

def evaluate(tree, genv, lenv)
  case tree[0]
  when 'func_def'
    genv[tree[1]] = ['user_defined', tree[2], tree[3]]
  when 'if'
    if evaluate(tree[1], genv, lenv)
      evaluate(tree[2], genv, lenv)
    else
      evaluate(tree[3], genv, lenv)
    end
  when 'while'
    while evaluate(tree[1], genv, lenv)
      evaluate(tree[2], genv, lenv)
    end
  when 'while2'
    evaluate(tree[2], genv, lenv)
    while evaluate(tree[1], genv, lenv)
      evaluate(tree[2], genv, lenv)
    end
  when 'lit'
    tree[1]
  when '+'
    lenv['plus_count'] += 1 if lenv['plus_count']
    evaluate(tree[1], genv, lenv) + evaluate(tree[2], genv, lenv)
  when '-'
    evaluate(tree[1], genv, lenv) - evaluate(tree[2], genv, lenv)
  when '*'
    evaluate(tree[1], genv, lenv) * evaluate(tree[2], genv, lenv)
  when '/'
    evaluate(tree[1], genv, lenv) / evaluate(tree[2], genv, lenv)
  when '%'
    evaluate(tree[1], genv, lenv) % evaluate(tree[2], genv, lenv)
  when '**'
    evaluate(tree[1], genv, lenv) ** evaluate(tree[2], genv, lenv)
  when '=='
    evaluate(tree[1], genv, lenv) == evaluate(tree[2], genv, lenv)
  when '!='
    evaluate(tree[1], genv, lenv) != evaluate(tree[2], genv, lenv)
  when '<'
    evaluate(tree[1], genv, lenv) < evaluate(tree[2], genv, lenv)
  when '<='
    evaluate(tree[1], genv, lenv) <= evaluate(tree[2], genv, lenv)
  when '>'
    evaluate(tree[1], genv, lenv) > evaluate(tree[2], genv, lenv)
  when '>='
    evaluate(tree[1], genv, lenv) >= evaluate(tree[2], genv, lenv)
  when 'func_call'
    args = []
    i = 0
    while tree[i + 2]
      args[i] = evaluate(tree[i + 2], genv, lenv)
      i = i + 1
    end
    mhd = genv[tree[1]]
    if mhd[0] == 'builtin'
      minruby_call(mhd[1], args)
    else
      params = mhd[1]
      i = 0
      while params[i]
        lenv[params[i]] = args[i]
        i = i + 1
      end
      evaluate(mhd[2], genv, lenv)
    end
  when 'stmts'
    i = 1
    last = nil
    while tree[i]
      last = evaluate(tree[i], genv, lenv)
      i += 1
    end
    last
  when 'var_assign'
    lenv[tree[1]] = evaluate(tree[2], genv, lenv)
  when 'var_ref'
    lenv[tree[1]]
  when 'ary_new'
    ary = []
    i = 0
    while tree[i + 1]
      ary[i] = evaluate(tree[i + 1], genv, lenv)
      i = i + 1
    end
    ary
  when 'ary_assign'
    ary = evaluate(tree[1], genv, lenv)
    idx = evaluate(tree[2], genv, lenv)
    val = evaluate(tree[3], genv, lenv)
    ary[idx] = val
  when 'ary_ref'
    ary = evaluate(tree[1], genv, lenv)
    idx = evaluate(tree[2], genv, lenv)
    ary[idx]
  when 'hash_new'
    hsh = {}
    i = 0
    while tree[i + 1]
      key = evaluate(tree[i + 1], genv, lenv)
      val = evaluate(tree[i + 2], genv, lenv)
      hsh[key] = val
      i = i + 2
    end
    hsh
  end
end

def max(tree)
  if tree[0] == 'lit'
    tree[1]
  else
    left = max(tree[1])
    right = max(tree[2])
    left > right ? left : right
  end
end

def add(x, y)
  x + y
end

def fizzbuzz(i)
  if i % 15 == 0
    'fizzbuzz'
  elsif i % 5 == 0
    'buzz'
  elsif i % 3 == 0
    'fizz'
  else
    i.to_s
  end
end

str = minruby_load()
tree = minruby_parse(str)
pp tree
genv = { 'p' => ['builtin', 'p'], 'add' => ['builtin', 'add'], 'fizzbuzz' => ['builtin', 'fizzbuzz'] }
lenv = {}
answer = evaluate(tree, genv, lenv)
