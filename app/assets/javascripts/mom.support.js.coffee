mom.support = {}

mom.support.enabled  = true # Toggle to disable support
mom.support.interval = 20   # In seconds
mom.support.timer    = null

mom.support.init = (startPolling) ->
  $('img.help').click (e) ->
    helpBox = $(e.target).attr('data-help')

    $('#' + helpBox).slideToggle()

  $('div.help-box img.close').click (e) ->
    $(e.target).parent().slideUp()

  if startPolling == true
    mom.support.startPolling()

mom.support.startPolling = ->
  interval = mom.support.interval * 1000
  mom.support.timer ||= setInterval(mom.support.checkForRequests, interval)

  $('#help_link').click ->
    $('#help_loading').show()
    $(this).hide()

mom.support.checkForRequests = ->
  if mom.support.enabled
    $.getJSON '/active_support_requests.json', (data) ->
      mom.support.processRequests(data)
  else
    clearInterval(mom.support.timer)

mom.support.processRequests = (data) ->
  if data.requests.length > 0
    text    = "Help needed at " + data.requests
    options = {
      icon:      '/assets/activebar/icon.png'
      button:    '/assets/activebar/close.png'
      highlight: 'InfoBackground'
      border:    'InfoBackground'
    }

    if $.fn.activebar.container != null
      $('.content',$.fn.activebar.container).html(text)
      $.fn.activebar.updateBar(options)

      unless $.fn.activebar.container.is(':visible')
        $.fn.activebar.show()
    else
      $('<div></div>').html(text).activebar(options)

  else if data.help_requested
    mom.support.showSupportRequested(data.request_id)
  else
    if $('#activebar-container').is(":visible")
      $.fn.activebar.hide()

mom.support.showSupportRequested = (id) ->
  mom.support.enabled = false

  $('#help_link').hide() if $('#help_link') != null

  text = "Help is on the way. <span style='float:right'> " +
    "Click here to cancel your request:</span>"

  closeCallback = ->
    $.ajax
      type: "PUT",
      url: '/support_requests/' + id,
      dataType: "script"

  options =
    icon:       '/assets/activebar/icon.png'
    button:     '/assets/activebar/close.png'
    highlight:  'none repeat scroll 0 0 #d23234'
    background: 'none repeat scroll 0 0 #d23234'
    border:     '#d23234'
    fontColor:  'white'
    onClose:    closeCallback

  if $.fn.activebar.container != null
    $('.content',$.fn.activebar.container).html(text)
    $.fn.activebar.updateBar(options)

    unless $.fn.activebar.container.is(':visible')
      $.fn.activebar.show()
  else
    $('<div></div>').html(text).activebar(options)
