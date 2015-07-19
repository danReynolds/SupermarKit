$ ->
  if grocery_id?

    # ============================
    # Grocery Table Setup
    # ============================
    table_initialized = false

    $grocery_table = $('#grocery-table').dataTable
      responsive: true
      LengthChange: false
      iDisplayLength: 5
      bLengthChange: false
      oLanguage:
        sSearch: 'Filter:'
        sEmptyTable: 'Your grocery list is empty.'

      ajax:
        url: "/groceries/#{grocery_id}/items.json"
        dataSrc: (json) ->
          json = formatItems(json)

      columnDefs: [
        { 'class': 'never', 'targets': 0 }
        { 'class': 'min-tablet-l', 'targets': 2 }
        { 'class': 'min-tablet-p', 'targets': 3 }
        { 'class': 'min-tablet-l', 'targets': 5 }
      ]

      fnInitComplete: ->
        $('.grocery-spinner').hide()
        $('.grocery-content').show()
        table_initialized = true

      fnDrawCallback: ->
        if table_initialized
          $('.reload').show()
          $('.recipe-content').hide()
          $('.recipe-no-content').hide()
        $(document).foundation('dropdown', 'reflow')

      footerCallback: (row, data, start, end, display) ->
        api = @api()

        # Remove the formatting to get integer data for summation
        intVal = (i) ->
          (if typeof i is 'string' then i.replace(/[\$,]/g, '') * 1 else (if typeof i is 'number' then i else 0))

        if (api.column(5).data().length > 0)
        # Total over all pages
          total = api.column(5).data().reduce (a, b) ->
            intVal(a) + intVal(b)

          # Update footer
          $(api.column(6).footer()).html "$#{intVal(total).toFixed(2)} total"
        else
          $(api.column(6).footer()).html '$0 total'

      createdRow: (row, data, index) ->
        $.fn.editable.defaults.mode = 'popup'
        $.fn.editable.defaults.ajaxOptions = type: 'PATCH'

        $(row).find('.editable').editable
          placement: 'bottom'
          emptytext: 'Add...'
          highlight: '#2CDF79'

          success: ->
            $grocery_table.api().ajax.reload(null, false)
          error: (e) ->
            console.log("e");

          params: (params) ->
            params.item = id: params.pk.item_id

            if this.name == 'groceries_items_quantity'
              params.item.groceries_items_attributes =
                '0':
                  'quantity': params.value
                  id: params.pk.groceries_items_id

            else if (this.name == 'groceries_items_price')
              params.item.groceries_items_attributes =
                '0':
                  'price': params.value
                  id: params.pk.groceries_items_id
            else
              params.item[this.name] = params.value

            return params

    $grocery_table.on 'click', 'tr td:first-child:not(.child)', ->
      $(this).parents('tbody').find('.child a').editable
        placement: 'bottom'
        emptytext: 'Add...'
        highlight: '#2CDF79'

        success: ->
          $grocery_table.api().ajax.reload(null, false)
          
        params: (params) ->
          params.item = id: params.pk.item_id

          if this.name == 'groceries_items_quantity'
            params.item.groceries_items_attributes =
              '0':
                'quantity': params.value
                id: params.pk.groceries_items_id

          else if this.name == 'groceries_items_price'
            params.item.groceries_items_attributes =
              '0':
                'price': params.value
                id: params.pk.groceries_items_id

          else
            params.item[this.name] = params.value

          return params

    # ============================
    # Row Removal
    # ============================

    $('.main').on 'click', '.remove', ->
      row = $(@).parents('tr')
      row_id = $grocery_table.fnGetPosition($(@).parents('tr')[0])
      item_id = $grocery_table.fnGetData(row)[0]
      $.ajax
        method: 'PATCH'
        url: "/items/#{item_id}/remove/?grocery_id=#{grocery_id}"
        success: ->
          $grocery_table.api().row(row).remove().draw()

    # ============================
    # Finish List Functionality
    # ============================

    dragula = require('dragula')

    dragula([$('.drag.left')[0], $('.drag.right')[0]],
      moves: (el, container, handle) ->
        true
        # elements are always draggable by default
      accepts: (el, target, source, sibling) ->
        true
        # elements can be dropped in any of the `containers` by default
      direction: 'vertical'
      copy: false
      revertOnSpill: false
      removeOnSpill: false
    ).on('drag', (el) ->
      el.classList.add('selected')
    ).on('dragend', (el) ->
      el.classList.remove('selected')
    )

    $('a[data-reveal-id="carry-over-modal"]').click ->
      modal = $(@).attr('data-reveal-id')

      $.get "/groceries/#{grocery_id}/items.json", (data) ->
        items = formatCarryOver(data)
        $('.drag.left').html('')
        $('.drag.right').html('')
        $.each items, (i, item) ->
          $('.drag.left').append(item)

    $('.drag-items').on 'click', '.item .remove', ->
      $(@).parents('.item').remove()

    $('.finish').submit ->
      ids = []
      for item in $('.drag.left .item')
        ids.push($(item).attr('value'))
      $('#finish_current_ids').val(ids)

      ids = []
      for item in $('.drag.right .item')
        ids.push($(item).attr('value'))
      $('#finish_next_ids').val(ids)

      $(@).submit()

    # ============================
    # Typeahead setup
    # ============================

    setup_typeahead($('.groceries-show #items_ids'), $grocery_table, $('form.items'), grocery_id)

    # ============================
    # Recipe Functionality
    # ============================
    recipe_initialized = false
    recipes = []

    reloadRecipes = ->
      $('.recipe-spinner').show()
      $('.recipe-content').hide()
      $('.recipe-no-content').hide()

      $.get "/groceries/#{grocery_id}/items.json", (items) ->
        ingredients = $.map items.data, (item, i) ->
          item.name

        if ingredients.length > 0
          ingredients = ingredients.join(',')

          $.ajax
            url: "/groceries/#{grocery_id}/recipes.json"
            success: (data) ->
              $('.recipe-spinner').hide()
              $('.recipe-content').show()
              recipes = data.recipes

              if recipes.length > 0
                _.each _.first(recipes, 8), (recipe) ->
                  $('#recipes ul').append(
                    "<li><img src=#{recipe.image_url}>
                    </img><div class=orbit-caption><div>#{recipe.title}</div>
                    <a class='button' target='_blank' href='#{recipe.source_url}'>Go to recipe</a></div></li>"
                  )
              else
                $('.recipe-content').hide()
                $('.recipe-no-content').show()

              if !recipe_initialized
                $('#recipes ul').attr('data-orbit', '')
                $(document).foundation('orbit', 'reflow')
                recipe_initialized = true
        else
          $('.recipe-spinner').hide()
          $('.recipe-no-content').show()

    # Call on inital page load
    reloadRecipes()

    $('.reload').on 'click', 'a', ->
      $('.reload').hide()
      $('#recipes ul').html('')
      reloadRecipes()

    # ============================
    # Email Functionality
    # ============================
    $('.email a').click ->
      $('.email-spinner').show()
      $('.email-content').hide()
