$ ->
  if page == "home"
    new Waypoint (
      element: $(".slide-left")
      handler: (direction) ->
        $(this.element).css('visibility', 'visible')
        $(this.element).addClass('animated fadeInLeft')
        this.disable()
      offset: '60%'
    )

    new Waypoint (
      element: $(".slide-right")
      handler: (direction) ->
        $(this.element).css('visibility', 'visible')
        $(this.element).addClass('animated fadeInRight')
        this.disable()
      offset: '60%'
    )

    new Waypoint (
      element: $(".slide-down")
      handler: (direction) ->
        $(this.element).css('visibility', 'visible')
        $(this.element).addClass('animated fadeInDown')
        this.disable()
      offset: '60%'
    )

