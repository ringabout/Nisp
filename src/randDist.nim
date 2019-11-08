import random, math, fenv, sequtils

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
  ## poisson distribution
  var
    b = 1.0
    i = 0
  b *= rand(1.0)
  while b >= exp(-lam):
    i += 1
    b *= rand(1.0)
  result = T(i)

proc aram*[T: SomeFloat](a, b: seq[float]; mu, sigma: float; n: int,
    gaussLen: int = 12): seq[T] =
  let
    p = a.len - 1
    q = b.len - 1
  var w = newSeqUninitialized[float](n)
  result = newSeqUninitialized[float](n)
  for i in 0 ..< n:
    w[i] = gauss[float](mu, sigma, gaussLen)
  result[0] = b[0] * w[0]
  for k in 1 .. p:
    var s = 0.0
    for i in 1 .. k:
      s += a[i] * result[k-i]
    s = b[0] * w[k] - s
    if q == 0:
      result[k] = s
      continue
    let m = if q > k: k else: q
    for i in 1 .. m:
      s += b[i] * w[k-i]
    result[k] = s
  for k in p+1 ..< n:
    var s = 0.0
    for i in 1 .. p:
      s += a[i] * result[k-i]
    s = b[0] * w[k] - s
    if q == 0:
      result[k] = s
      continue
    for i in 1 .. q:
      s += b[i] * w[k-i]
    result[k] = s

proc sinWhiteNoise*[T: SomeFloat](a, freq, phase: seq[float]; fs, snr: float;
    n: int): seq[T] =
  let
    m = a.len
    z = pow(10.0, snr / 10.0)
    nsr = sqrt(1.0 / (2.0 * z))
  var
    f = freq.mapIt(2.0 * Pi * it / fs)
    p = phase.mapIt(it * Pi / 180.0)
  result = newSeqUninitialized[float](n)
  for i in 0 ..< n:
    for j in 0 ..< m:
      result[i] += a[j] * sin(f[j] * float(i) + p[j])
    result[i] += nsr * gauss[float](0.0, 1.0)

when isMainModule:
  import plotly, sugar, sequtils, chroma, os
  randomize()
  # var res: seq[float] = aram[float](@[1.0, 1.45, 0.6], @[1.0, -0.2, -0.1], 0.0, 0.5, 200)
  var res: seq[float] = sinWhiteNoise[float](@[1.0, 1.0, 1.0], @[10.0, 17.0,
      50.0], @[45.0, 10.0, 88.0], 150.0, 5.0, 200)

  var colors = @[Color(r: 0.1, g: 0.1, b: 0.9, a: 1.0)]

  var d = Trace[float](mode: PlotMode.LinesMarkers, `type`: PlotType.Scatter)
  var size = @[1.float]
  d.marker = Marker[float](size: size, color: colors)
  d.xs = toSeq(1 .. res.len).map(x => x.float)
  d.ys = res
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



