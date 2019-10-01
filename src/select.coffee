import RfInput from './input'
import pt from 'prop-types'

export default class RfSelect extends RfInput
  @propTypes: {
    ...RfInput.propTypes
    options: pt.arrayOf(pt.object).isRequired
  }

  options: ->
    @props.options

  renderOptions: ->
    @options().map(@renderOption)

  renderOption: ->
    throw "this.renderOption method for RfSelect wasn't implemented"
