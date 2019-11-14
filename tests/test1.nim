import math, timeit


echo [1, 2, 3, 4][1 .. 3]


timeOnce("test test"):
  echo ln(0.0)

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

