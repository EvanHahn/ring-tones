RING_COUNT = 10
TWOPI = Math.PI * 2
NOTES = []

[3..7].forEach (octave) ->
  tsw.scale('C', 'major').forEach (note) ->
    NOTES.push tsw.frequency("#{note}#{octave}")

canvas = document.createElement 'canvas'
ctx = canvas.getContext '2d'
canvas.width = window.innerWidth
canvas.height = window.innerHeight
$html = $('html')
$('body').append canvas
center =
  x: canvas.width / 2
  y: canvas.height / 2

maxRadius = Math.sqrt(center.x * center.x + center.y * center.y)
ringSize = maxRadius / RING_COUNT
clicking = false

ringFrom = (event) ->
  mouseX = Math.abs(event.offsetX - center.x)
  mouseY = Math.abs(event.offsetY - center.y)
  distanceFromCenter = Math.sqrt(mouseX * mouseX + mouseY * mouseY)
  index = Math.floor(distanceFromCenter / ringSize)
  return rings[index]

class Ring

  constructor: (@radius) ->

    @randomizeColor()
    @saturation = 0

    @held = no

    noteIndex = Math.floor(radius / ringSize) % NOTES.length
    @volume = tsw.gain(0)
    @oscillator = tsw.oscillator('sine', NOTES[noteIndex])
    tsw.connect(@oscillator, @volume, tsw.speakers)
    @oscillator.start()

  randomizeColor: ->
    @baseColor = Spectra.random().darken(40 * (@radius / maxRadius))

  lightUp: ->
    @randomizeColor() if @saturation is 0
    @saturation = 1

  tick: ->
    @volume.gain(@saturation)
    if @held
      @lightUp()
    else
      @saturation = Math.max(0, @saturation - 0.01)

  draw: ->
    if @held
      color = Spectra('white')
    else
      color = Spectra(@baseColor.hex()).saturation(@saturation)
    ctx.fillStyle = color.hex()
    ctx.beginPath()
    ctx.arc center.x, center.y, @radius, 0, TWOPI
    ctx.fill()

rings = []

for radius in [1..RING_COUNT]
  rings.push new Ring(radius * ringSize)

do tick = ->

  for ring in rings by -1
    ring.tick()
    ring.draw()

  requestAnimationFrame tick

$html.on 'mousemove', (event) ->
  ringFrom(event).lightUp()

$html.on 'click', ->
  ring = ringFrom(event)
  ring.held = true
