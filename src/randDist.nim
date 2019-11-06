import random, math, fenv

var
  randomSeed*: int = 0


proc zeroHandle*[T: SomeFloat](value: var T) {.inline.} =
  if value == 0.0:
    value += epsilon(T)

proc oneHandle*[T: SomeFloat](value: var T) {.inline.} =
  if value == 1.0:
    value -= epsilon(T)

proc uniformDist*[T: SomeFloat](left: T, right: T,
    seed: int = randomSeed): T =
  ## uniform distribution
  randomSeed = seed
  randomSeed = 2045 * randomSeed + 1
  randomSeed = randomSeed mod 1048576
  result = randomSeed / 1048576
  result = left + (right - left) * result

proc uniformDistSeq*[T: SomeFloat](left: T, right: T, size: int = 8,
    seed: int = randomSeed): seq[T] =
  ## uniform distribution seqs
  randomSeed = seed
  for i in 0 ..< size:
    result.add(uniformDist[T](left, right, randomSeed))


proc gauss*[T: SomeFloat](mu, sigma: float, n: int = 12): T {.inline.} =
  ## gauss distribution
  ## N(mu, sigma)
  var x: float
  for i in 1 .. n:
    # randomize()
    x += rand(1.0)
  x -= 6.0
  result = mu + sigma * x

proc exponent*[T: SomeFloat](beta: float): T {.inline.} =
  ## exponent distribution
  var u = rand(1.0)
  zeroHandle(u)
  result = -beta * ln(u)

proc laplace*[T: SomeFloat](beta: float): T {.inline.} =
  ## laplace distribution
  var u = rand(1.0)
  if u <= 0.5:
    zeroHandle(u)
    result = -beta * ln(1.0 - u)
  else:
    oneHandle(u)
    result = beta * ln(u)

proc rayleigh*[T: SomeFloat](sigma: float): T {.inline.} =
  ## rayleigh distribution
  var u = rand(1.0)
  zeroHandle(u)
  result = sigma * sqrt(-2.0 * ln(u))

proc lognorm*[T: SomeFloat](mu, sigma: float): T {.inline.} =
  ## log-gauss distribution
  result = exp(gauss(mu, sigma))

proc cauchy*[T: SomeFloat](alpha, beta: float): T {.inline.} =
  ## cauchy distribution
  var u = rand(1.0)
  result = alpha - beta / tan(Pi * u)

proc weibull*[T: SomeFloat](alpha, beta: float): T {.inline.} =
  ## weibull distribution
  assert alpha > 0.0
  var u = rand(1.0)
  zeroHandle(u)
  result = beta * pow(-ln(u), 1.0 / alpha)

proc erlang*[T: SomeFloat](m: int, beta: float): T {.inline.} =
  ## erlang distribution
  var u: float = 1.0
  for i in 1 .. m:
    u *= rand(1.0)
  zeroHandle(u)
  result = -beta * ln(u)

proc bernoulli*[T: SomeFloat](p: float): T {.inline.} =
  ## bernoulli distribution
  var u: float = rand(1.0)
  if u <= p:
    result = 1.0
  else:
    result = 0.0

proc bernoulliGauss*[T: SomeFloat](p, mu, sigma: float, n: int = 12): T {.inline.} =
  ## bernoulli-gauss distribution
  var u: float = rand(1.0)
  if u <= p:
    result = gauss(mu, sigma, n)
  else:
    result = 0.0

proc bin*[T: SomeFloat](n, p: float): T {.inline.} = 
  ## binom distribution
  for i in 1 .. n:
    result += bernoulli(p)

proc poisson*[T: SomeFloat](lam, s: float): T {.inline.} = 
  var
    b = 1.0
    i = 0
  b *= rand(1.0)
  while b >= exp(-lam):
    i += 1
    b *= rand(1.0)
  result = T(i)
  


when isMainModule:
  import plotly, sugar, sequtils, chroma, os
  randomize()
  var res: seq[float]
  for i in 1 .. 1000000:
    res.add bernoulli[float](0.2)

  var colors = @[Color(r: 0.1, g: 0.1, b: 0.9, a: 1.0)]

  var d = Trace[float](`type`: PlotType.Histogram, nbins: 2000)
  var size = @[1.float]
  d.marker = Marker[float](size: size, color: colors)
  d.xs = res
  # d.xs = toSeq(1 .. d1.size).map(x => x / 16000)
  # d.xs = frame2Time(d1.size, 200, 80, 16000)
  # d.ys = d1.toSeq
  d.text = @["hello", "data-point", "third", "highest", "<b>bold</b>"]

  var layout = Layout(title: "weibull", width: 1200, height: 400,
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



