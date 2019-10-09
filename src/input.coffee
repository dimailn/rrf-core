import React from 'react'
import pt from 'prop-types'
import {debounce} from 'lodash'


export default class RfInput extends React.Component
  componentDidMount: ->
    @context.rfBus.addEventListener('onChange', @update)
    @context.rfBus.addEventListener('invalidate', @invalidate)

  componentWillUnmount: ->
    @context.rfBus.removeEventListener('onChange', @update)
    @context.rfBus.removeEventListener('invalidate', @invalidate)    

  invalidate: (e) =>
    return unless e.target.name is @props.name

    @forceUpdate()

  update: (e) =>
    e.target.name is @props.name && @forceUpdate()

  @contextTypes:
    rfGet: pt.func
    rfSet: pt.func
    rfGetErrors: pt.func
    rfFormName: pt.string
    rfBus: pt.object

  @propTypes:
    name: pt.string
    type: pt.string
    onChange: pt.func
    contextualOnChange: pt.func
    translateKey: pt.string

  get: (args...) =>
    @context.rfGet(args...)

  set: (args...) =>
    @context.rfSet(args...)

  getValue: =>
    value = @get(@props.name)

    return value unless @props.type is 'number'
    return value.toString() if value
    ''

  onChange: (value) =>
    parsingFunction = if @props.integer then parseInt else parseFloat
    skipParse =
    if @props.type is 'number'
      value = value.replace(',', '.')
      skipParse = value.endsWith('.')
      value = parsingFunction(value) unless skipParse
      value = '' if isNaN(value)
    @set(@props.name, value)
    @context.rfBus.dispatch('onChange', {name: @props.name})
    @props.onChange?(value)
    @props.contextualOnChange?.bind(@)(value)

  getLabel: =>
    formName = @props.translateKey || @context.rfFormName
    (global || window).rrfTranslate(formName, @props.name)

  getFirstError: =>
    errors = @context.rfGetErrors(@props.name)
    return errors.join(', ') if errors instanceof Array
    errors

  hasErrors: ->
    !!@getFirstError()
