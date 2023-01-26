extends Node2D

const Width = 50
const Height = 50
const Kl = preload("res://Klyaksa.tscn")

onready var l = $Label

var T1 = []
var T2 = []
var T3 = []
var ArrObjects = []
var FramesPerStep = 15
var FPS = FramesPerStep
var Pause = true
var mPosition
var x
var y
var drawing = false
var cur_draw_cell = null


func _ready():
	var K
	randomize()
	for i in Width+2:
		T1.append([])
		T2.append([])
		ArrObjects.append([])
		for j in Height+2:
			T1[i].append(randi()%10)
			T2[i].append(0)
			K = Kl.instance()
			K.position.x = (i-1)*16
			K.position.y = (j-1)*16
			if T1[i][j] == 1:
				K.visible = true
			else:
				K.visible = false
				T1[i][j] = 0
			ArrObjects[i].append(K)
			add_child(K)
	for i in Width+2:
		ArrObjects[i][0].visible = false
		ArrObjects[i][51].visible = false
		T1[i][0] = 0
		T1[i][51] = 0
	for j in Height+2:
		ArrObjects[0][j].visible = false
		ArrObjects[51][j].visible = false
		T1[0][j] = 0
		T1[51][j] = 0


func _input(event):
	if !Pause: return
	if event is InputEventMouseButton:
		if event.is_action_pressed("click"):
			drawing = true
			change_cell(event.position)
		elif event.is_action_released("click"):
			drawing = false
			cur_draw_cell = null
	if event is InputEventMouseMotion and drawing and event.position.y < 800:
		change_cell(event.position)


func _physics_process(_delta):
	l.text = "Frames per step=" + str(FramesPerStep) + " (UP, DOWN to change.)"
	if Pause:
		l.text += "   Pause (SPACE) and draw (MOUSE CLICK). BACKSPACE to clear."
	else:
		l.text += "   SPACE to pause."
	if Input.is_action_just_pressed("ui_accept"):
		Pause = !Pause
	if Input.is_action_just_pressed("ui_up"):
		FramesPerStep -= 1
		if FramesPerStep < 1: FramesPerStep = 1
	elif Input.is_action_just_pressed("ui_down"):
		FramesPerStep += 1
	if Input.is_action_just_pressed("clear") and Pause:
		for i in Width+2:
			for j in Height+2:
				T1[i][j] = 0
				T2[i][j] = 0
				ArrObjects[i][j].visible = false
	if !Pause:
		FPS -= 1
		if FPS <= 0:
			FPS = FramesPerStep
			NewStep()
			DrawLive()


func change_cell(pos: Vector2):
	x = pos.x/16+1
	y = pos.y/16+1
	if ArrObjects[x][y] != cur_draw_cell:
		ArrObjects[x][y].visible = !ArrObjects[x][y].visible
		cur_draw_cell = ArrObjects[x][y]
		if T1[x][y] == 0:
			T1[x][y] = 1
		else:
			T1[x][y] = 0


func NewStep():
	var Sum = 0
	for i in Width:
		for j in Height:
			Sum = T1[i][j]+T1[i+1][j]+T1[i+2][j] + T1[i][j+1]+T1[i+2][j+1] + T1[i][j+2]+T1[i+1][j+2]+T1[i+2][j+2]
			if Sum < 2 or Sum > 3:
				T2[i+1][j+1] = 0
			elif Sum == 3:
				T2[i+1][j+1] = 1
			else:
				T2[i+1][j+1] = T1[i+1][j+1]
	T3 = T1
	T1 = T2
	T2 = T3


func DrawLive():
	for i in Width:
		for j in Height:
			if T1[i+1][j+1] == 1:
				ArrObjects[i+1][j+1].visible = true
			else:
				ArrObjects[i+1][j+1].visible = false

