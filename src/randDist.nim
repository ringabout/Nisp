var
  randomSeed*: int = 0


proc uniformDist*[T: SomeFloat](left: T, right: T,
    seed: int = randomSeed): T =
  randomSeed = seed
  randomSeed = 2045 * randomSeed + 1
  randomSeed = randomSeed mod 1048576
  result = randomSeed / 1048576
  result = left + (right - left) * result

# 一维数组
proc uniformDistSeq*[T: SomeFloat](left: T, right: T, size: int = 8,
    seed: int = randomSeed): seq[T] =
  randomSeed = seed
  for i in 0 ..< size:
    result.add(uniformDist[T](left, right, randomSeed))


when isMainModule:
  import timeit
  timeOnce:
    echo uniformDistSeq[float](-2.0, 3.0, 10, 12)



