RING_COUNT = 20
TWOPI = Math.PI * 2
NOTES = []

[4..6].forEach (octave) ->
  scale = tsw.scale('C', 'major')
  scale.forEach (note, index) ->
    if scale.length - 1 isnt index
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
  mouseX = Math.abs(event.clientX - center.x)
  mouseY = Math.abs(event.clientY - center.y)
  distanceFromCenter = Math.sqrt(mouseX * mouseX + mouseY * mouseY)
  index = Math.floor(distanceFromCenter / ringSize)
  return rings[index] or { lightUp: -> } # fake ring

class Ring

  constructor: (@radius) ->

    @randomizeColor()
    @saturation = 0

    noteIndex = (Math.floor(@radius / ringSize) - 1) % NOTES.length
    @volume = tsw.gain(0)
    @oscillator = tsw.oscillator('sine', NOTES[noteIndex])
    tsw.connect(@oscillator, @volume, tsw.speakers)
    @oscillator.start()

  randomizeColor: ->
    @baseColor = Spectra.random()

  lightUp: ->
    @randomizeColor() if @saturation is 0
    @saturation = 1

  tick: ->
    @volume.gain(@saturation)
    @saturation = Math.max(0, @saturation - 0.01)

  draw: ->
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

$html.on 'mousemove', (event) -> ringFrom(event).lightUp() if clicking
$html.on 'mousedown', (event) ->
  clicking = yes
  ringFrom(event).lightUp()
$html.on 'mouseup', -> clicking = no
