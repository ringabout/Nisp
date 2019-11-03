import random, math

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

# 正态分布的随机数
# N(mu, sigma)
proc gauss*[T: SomeFloat](mu, sigma: T, n: int = 12): T =
  var x: float
  for i in 1 .. n:
    # randomize()
    x += rand(1.0)
  x -= 6.0
  result = mu + sigma * T(x)

# 指数分布的随机数
proc exponent*[T: SomeFloat](beta: T): T = 
  var u = rand(1.0)
  result = -beta * T(ln(u))


when isMainModule:
  import plotly, sugar, sequtils, chroma, os
  randomize()
  var res: seq[float]
  for i in 1 .. 1000000:
    res.add exponent[float](1)


  var colors = @[Color(r: 0.1, g: 0.1, b: 0.9, a: 1.0)]

  var d = Trace[float](`type`: PlotType.Histogram,nbins:5000)
  var size = @[1.float]
  d.marker = Marker[float](size: size, color: colors)
  d.xs = res
  # d.xs = toSeq(1 .. d1.size).map(x => x / 16000)
  # d.xs = frame2Time(d1.size, 200, 80, 16000)
  # d.ys = d1.toSeq
  d.text = @["hello", "data-point", "third", "highest", "<b>bold</b>"]

  var layout = Layout(title: "exp", width: 1200, height: 400,
                      xaxis: Axis(title: "x"),
                      yaxis: Axis(title: "y"), autosize: false)

  var p = Plot[float](layout: layout, traces: @[d])
  # 保存图像
  if not existsDir("./generate"):
    createDir("./generate")
  # run with --threads:on
  p.show(filename = "generate/display.jpg")




# when isMainModule:
#   import timeit
#   timeOnce:
#     echo uniformDistSeq[float](-2.0, 3.0, 10, 12)



