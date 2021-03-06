"
I am an executor in the workflow engine. To work i need context (WaveEngine) and flowHandler for handling the flow and determining the paths of execution.

In order to initialize, I need a node an initial which contains the information needed for execution.
The most basic execution would be from start to end node.

start := StartEvent new.
start description: 'StartEvent'.

end := EndEvent new.
end description: 'End Event ee'.

seq1 := Sequence source: start target: end.
start addOutgoingFlow: seq1.
end addIncomingFlow: seq1. 

we := WaveExecutor initialNode: start.

Internal Representation and Key Implementation Points.

    Instance Variables
	engine:		<Object>
	flowHandler:		<Object>
	taskResult:		<Object>
	waveAnnouncer:		<Object>
	workers:		<Object>


    Implementation Points
"
Class {
	#name : #WaveExecutor,
	#superclass : #Object,
	#instVars : [
		'waveAnnouncer',
		'taskResult',
		'flowHandler',
		'workers',
		'engine'
	],
	#category : #'NewWave-Engine'
}

{ #category : #'as yet unclassified' }
WaveExecutor class >> initialNode: node [
	| fh |
	fh := FlowHandler new.
	fh node: node.
	^ self new 
		flowHandler: fh;
		yourself
]

{ #category : #'as yet unclassified' }
WaveExecutor class >> initialNode: node engine: aEngine [
	| fh |
	fh := FlowHandler new.
	fh node: node.
	^ self new 
		flowHandler: fh;
		engine: aEngine;
		yourself
]

{ #category : #accessing }
WaveExecutor >> engine [
	^ engine
]

{ #category : #accessing }
WaveExecutor >> engine: anEngine [
	engine := anEngine
]

{ #category : #running }
WaveExecutor >> execute: elem [
	| elemHandler executor |
	elemHandler := BehaviorHandler new.
	executor := elemHandler behaviors at: elem ctype.
	executor performExecution: elem executor: self.
	
	
	
	
]

{ #category : #accessing }
WaveExecutor >> flowHandler [
	^ flowHandler
]

{ #category : #accessing }
WaveExecutor >> flowHandler: aFlowHandler [
	flowHandler := aFlowHandler
]

{ #category : #initialization }
WaveExecutor >> initialize [

	super initialize.
	self waveAnnouncer: Announcer new.
	self workers: Dictionary new.
]

{ #category : #'as yet unclassified' }
WaveExecutor >> returnTKT: aTask [
	^ TKTTask valuable: aTask.
]

{ #category : #accessing }
WaveExecutor >> shouldExecuteNextNewHandler [
	| tmp |
	tmp := flowHandler getNextElement.
	tmp ifNil: [ ^ nil ] ifNotNil: [ ^ tmp ].
]

{ #category : #accessing }
WaveExecutor >> taskResult [
	^ taskResult
]

{ #category : #accessing }
WaveExecutor >> taskResult: anObject [
	taskResult := anObject
]

{ #category : #tests }
WaveExecutor >> testExe [
| future |
future := [ 1 second wait. 2 + 2 ] future.
future onSuccessDo: [ :v | v logCr ].
]

{ #category : #accessing }
WaveExecutor >> tryToExecuteNext [
	| tmp |
	tmp := self shouldExecuteNextNewHandler.
	tmp ifNil: ['End of executing' logCr. ] ifNotNil: [self execute: tmp]
]

{ #category : #accessing }
WaveExecutor >> tryToExecuteNextOnWorker [
	"This is where I continue the execution after join. Because join is completed I want to continue executing on the worker inside this executor, so I can remove the existing SubExecutors."
	self worker schedule: [ self tryToExecuteNext. ].
]

{ #category : #accessing }
WaveExecutor >> waveAnnouncer [
	^ waveAnnouncer
]

{ #category : #accessing }
WaveExecutor >> waveAnnouncer: anObject [
	waveAnnouncer := anObject
]

{ #category : #accessing }
WaveExecutor >> worker [
	^ workers at: flowHandler workerid.
]

{ #category : #running }
WaveExecutor >> workers [
	^ workers
]

{ #category : #running }
WaveExecutor >> workers: aWorkers [
	workers := aWorkers
]
