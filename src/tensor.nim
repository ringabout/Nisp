# just for fun
# Some matrix
import randDist, random, sequtils

type
  Tensor*[T] = object
    data: seq[seq[T]]
    shape*: seq[T]

proc size*[T](s: Tensor[T]): int 
proc newTensor*[T](shape: varargs[int]): Tensor[T] {.noSideEffect,noInit, inline.}
proc `[]`*[T](s: Tensor[T]; a, b: int): Tensor[T]
proc `[]=`*[T](s: var Tensor[T]; a, b: int; val: T)
proc `$`*[T](s: Tensor[T]): string



proc size*[T](s: Tensor[T]): int = 
  s.shape[0] * s.shape[1]

proc newTensor*[T](shape: varargs[int]): Tensor[T] {.noSideEffect,noInit, inline.} =
  ## just support 2-D
  assert shape.len == 2
  let 
    rows = shape[0]
    cols = shape[1]
  result.data = newSeqWith(rows, newSeq[T](cols))

proc randomTensor*[T: SomeFloat](shape: varargs[int], max: T): Tensor[T] {.noinit, inline.} =
  result = newTensor[T](shape[0], shape[1]) 
  for i in 0 ..< shape[0]:
    for j in 0 ..< shape[1]:
      result[i, j] = rand(max)

proc gaussTensor*[T: SomeFloat](shape: varargs[int]; mu, sigma: float; n: int): Tensor[T] {.noinit, inline.} =
  result = newTensor[T](shape[0], shape[1]) 
  for i in 0 ..< shape[0]:
    for j in 0 ..< shape[1]:
      result[i, j] = gauss(mu, sigma, n)

proc randomTensor*(shape: varargs[int], max: int): Tensor[int] {.noinit, inline.} =
  result = newTensor[int](shape[0], shape[1]) 
  for i in 0 ..< shape[0]:
    for j in 0 ..< shape[1]:
      result[i, j] = int(rand(max))


proc `[]`*[T](s: Tensor[T]; a, b: int): Tensor[T] = 
  s.data[a][b]

proc `[]=`*[T](s: var Tensor[T]; a, b: int; val: T) = 
  s.data[a][b] = val

# proc `[]`*[T](s: Tensor[T], a: Slice[int], b: Slice[int])

proc `$`*[T](s: Tensor[T]): string = 
  $s.data

when isMainModule:
  var a = randomTensor[float](2, 5, max=3.0)
  echo a