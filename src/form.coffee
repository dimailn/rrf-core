import React from 'react'
import pt from 'prop-types'

import EventBus from 'eventbusjs'
import {isEqual, omit} from 'lodash'

export default class RfForm extends React.Component
  @propTypes:
    owner: pt.object.isRequired
    name: pt.string.isRequired
    errors: pt.object
    stateKey: pt.string

  @childContextTypes:
    rfGet: pt.func
    rfSet: pt.func
    rfGetErrors: pt.func
    rfFormName: pt.string
    rfBus: pt.object

  getChildContext: ->
    {
      rfGet: @get
      rfSet: @set
      rfGetErrors: @getErrors
      rfFormName: @props.name
      rfBus: EventBus
    }

  stateKey: ->
    @props.stateKey || @props.name

  get: (path) =>
    resource = @props.owner.state[@stateKey()]

    throw "Resource #{@props.name} was not found in state" unless resource?

    resource[path]

  set: (path, value) =>
    @dirty ||= true if @props.owner.state[path] isnt value
    {autoClearErrors} = @props
    @props.owner.setState((state) =>
      "#{@stateKey()}":{
        ...state[@stateKey()]
        "#{path}": value
      }
      errors: if autoClearErrors then omit(@props.errors, [path]) else @props.errors
    )

  componentDidUpdate: (prevProps, prevState) ->
    return if isEqual(@props.errors, prevProps.errors)

    Object.keys(@props.errors).forEach (name) ->
      EventBus.dispatch('invalidate', {name})

  componentDidMount: ->
    EventBus.addEventListener('onChange', @update)
    @dirty = false

  isDirty: =>
    @dirty

  setDirty: (@dirty) ->

  resetDirty: =>
    @dirty = false

  update: =>
    @forceUpdate()

  getErrors: (path) =>
    (@props.errors || {})[path]

  render: ->
    <React.Fragment>
      {@props.children}
    </React.Fragment>
