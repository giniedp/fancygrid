(function( $ ) {

  // Query format that is sent to the backend
  //{
  //  columns : [{ 
  //    identifier : <string>, 
  //    visible : <bool>, 
  //    position : <number> 
  //  }],
  //  conditions : [{ 
  //    identifier : <string>, 
  //    operator : <string>, 
  //    value : <string> 
  //  }], 
  //  operator : ["all"|"any"],
  //  order : { 
  //    identifier : <string>, 
  //    direction : ["asc"|"desc"|""] 
  //  },
  //  pagination : { 
  //    page : <number>, 
  //    per_page : <number> 
  //  }
  //}  

  var Fancygrid = this.Fancygrid = {};

  var setValue = function(element, v){
    $(element).each(function(index, item){
      var $item = $(item);
      if ($item.is("select") || $item.is("input")){
        $item.val(v);
      } else {
        $item.text(v);
      }
    });
  };
  
  var getValue = function(element){
    element = $(element).first();
    if (element.is("select") || element.is("input")){
      return element.val();
    }
    return element.text();
  };
  
  var FancygridWrapper = function(container, options){
    
    // setup setings and default values
    var settings = { 
      ajaxUrl        : "/", 
      ajaxType       : "GET",
      name           : "", 
      searchFadeTime : 25,
      searchFadeOpac : 0.5,
      page           : 1,
      perPage        : 25
    };
    options = (options || {});
    $.extend(settings, options);
    
    // cache parameters
    this.name = options.name;
    this.container = container;
    this.settings = settings;
    this.queries = 0;
    this.query = { 
      pagination      : { 
        page : (settings.page),
        per_page : settings.perPage
      },
      columns         : [],
      conditions      : [],
      operator        : "all",
      order           : {}
    };
    
    // cache components
    this.components = {
      container      : container,
      search         : container.find(".fg-search"),
      searchTemplate : container.find(".fg-search-template"),
      sortWindow     : container.find(".fg-sort-window"),
      sortContent    : container.find(".fg-sort-content"),
      controls       : container.find(".fg-control-bar"),
      dataWrapper    : container.find(".fg-datawrapper"),
      dataContainer  : container.find(".fg-datacontainer"),
      currentPage    : container.find(".fg-current-page"),
      totalPages     : container.find(".fg-total-pages"),
      perPage        : container.find(".fg-per-page"),
      buttons : {
        prevPage        : container.find(".fg-button-prev"),
        nextPage        : container.find(".fg-button-next"),
        refresh         : container.find(".fg-button-refresh"),
        clearSearch     : container.find(".fg-button-clear"),
        toggleSearch    : container.find(".fg-button-search"),
        toggleSort      : container.find(".fg-button-sort"),
        addCriterion    : container.find(".fg-button-add-criterion"),
        removeCriterion : container.find(".fg-button-remove-criterion")
      }
    };

    // hide components
    this.components.searchTemplate.hide();
    this.components.sortWindow.hide();
    this.components.sortContent.hide();
    if (!settings.searchVisible){
      this.components.search.hide();
    }
    
    var instance = this;
    
    // search attribute changed/focused
    this.components.search.find("input[type='text'], select").bind("change.fancygrid", function(){
      instance.buildConditions();
      instance.refresh();
    }).bind("focus.fancygrid", function(){
      $(this).select();
    });
    
    // search attribute changed/focused
    this.components.currentPage.bind("change.fancygrid", function(){
      instance.setPage(getValue($(this)));
      instance.refresh();
    }).bind("focus.fancygrid", function(){
      $(this).select();
    });
          
    // previous page click
    this.components.buttons.prevPage.bind("click.fancygrid", function(e){
      e.preventDefault();
      instance.flipPages(-1);
      instance.refresh();
    });
          
    // next page click
    this.components.buttons.nextPage.bind("click.fancygrid", function(e){
      e.preventDefault();
      instance.flipPages(1);
      instance.refresh();
    });
          
    // reload click
    this.components.buttons.refresh.bind("click.fancygrid", function(e){
      e.preventDefault();
      instance.refresh();
    });
    
    // clear click
    this.components.buttons.clearSearch.bind("click.fancygrid", function(e){
      e.preventDefault();
      instance.clearSearch();
      instance.refresh();
    });
    
    // per page change
    this.components.perPage.bind("change.fancygrid", function(e){
      e.preventDefault();
      instance.setPerPage(getValue($(this)));
      instance.refresh();
    });
    
    // magnifier click
    this.components.buttons.toggleSearch.bind("click.fancygrid", function(e){
      e.preventDefault();
      instance.toggleSearch();
    });
    
    // sort click
    this.components.buttons.toggleSort.bind("click.fancygrid", function(e){
      e.preventDefault();
      instance.toggleSort();
    });
    this.components.sortWindow.click(function(){
      instance.toggleSort();
    });
    
    // remove search criterion
    this.components.buttons.removeCriterion.click(function(e){
      e.preventDefault();
      instance.buildConditions();
      $(this).parents(".fg-search-criterion").detach();
    });
    
    // add search criterion
    this.components.buttons.addCriterion.click(function(e){
      e.preventDefault();
      instance.addSearchCriterion();
    });
    
    // 
    container.find(".fg-orderable").click(function(e){
      e.preventDefault();
      instance.toggleOrder($(this));
    });
  };

  FancygridWrapper.prototype.flipPages = function(value){
    return this.setPage(this.query.pagination.page + value);
  };
  
  FancygridWrapper.prototype.setPage = function(value){
    value = Math.max(1, value);
    this.query.pagination.page = value;
    setValue(this.components.currentPage, value);
    return value;
  };
  
  FancygridWrapper.prototype.setPages = function(value){
    value = Math.max(0, value);
    setValue(this.components.totalPages, value);
    return value;
  };
  
  FancygridWrapper.prototype.setPerPage = function(value){
    value = Math.max(1, value);
    this.query.pagination.per_page = value;
    setValue(this.components.perPage, value);
  };
  
  FancygridWrapper.prototype.setOrder = function(identifier, direction){
    this.query.order.identifier = identifier;
    this.query.order.direction = direction;
    this.container.find(".fg-orderable").attr("fg-sort-order", "");
    this.container.find(".fg-orderable[fg-identifier='" + identifier + "']").attr("fg-sort-order", direction);
    return this.query.order;
  };
  
  FancygridWrapper.prototype.toggleOrder = function(column){
    var identifier = column.attr("fg-identifier");
    var direction = column.attr("fg-sort-order");

    if (direction == "asc"){
      direction = "desc";
    } else if (direction == "desc"){
      direction = "";
    } else {
      direction = "asc";
    }
    
    this.setOrder(identifier, direction);
    this.refresh();
  };
  
  FancygridWrapper.prototype.toggleSort = function(){
    this.components.sortWindow.css({
      position : "absolute",
      top : 0,
      left : 0,
      width : "100%",
      height : "100%",
      opacity : 0.5
    });
    this.components.sortContent.css({
      position : "absolute",
      top : (window.innerHeight * 0.25) / 2,
      left : (window.innerWidth - 200) / 2,
      width : 200
    });
    var instance = this;
    this.components.sortContent.find("input[type=submit]").click(function(){
      instance.submitSort();
      return false;
    });
    
    this.components.sortContent.find(".fg-sortable").sortable();
    this.components.sortContent.find(".fg-sortable").disableSelection();
    
    this.components.sortWindow.toggle();
    this.components.sortContent.toggle();
  };

  FancygridWrapper.prototype.submitSort = function(){
    this.buildColumns();
    this.refresh(function(){
      window.location.reload();
    });
  };
    
  FancygridWrapper.prototype.clearSearch = function(){
    // clear the complex search
    this.container.find(".fg-search li.fg-search-criterion").detach();
    // empty the simple search input fields
    this.container.find(".fg-search-criterion *[name='value']").val("");
    this.query.conditions = [];
    return this.query.conditions;
  };
  
  FancygridWrapper.prototype.buildColumns = function(){
    var inputs = this.components.sortContent.find(".fg-sort-item input");
    var items = this.query.columns = [];
    inputs.each(function(index, item){
       item = $(item);
       items.push({
         identifier : item.attr("name"),
         visible : item.is(":checked"),
         position : index
       });
    });    
    return this.query.columns;
  };

  FancygridWrapper.prototype.buildConditions = function(){
    this.query.operator = this.container.find("#fg-search-conditions:checked").val() || "all";
    var conditions = this.query.conditions = [];
    this.components.search.find(".fg-search-criterion").each(function(){
      conditions.push({
        identifier : getValue($(this).find("#identifier")),
        operator : getValue($(this).find("#operator")),
        value : getValue($(this).find("#value"))
      });
    });
    return this.query;
  };

  FancygridWrapper.prototype.toggleSearch = function(){
    this.components.search.toggle();
    this.query.search_visible = this.components.search.is(":visible");      
    return this.query.search_visible;
  };

  FancygridWrapper.prototype.addSearchCriterion = function(){
    if (!this.components.searchTemplate){
      return false;
    }
    
    var instance = this;
    var template = $(this.components.searchTemplate.html());
    this.components.search.find(".fg-search-criteria").append(template);
    
    // remove criterion binding
    template.find(".fg-button-remove-criterion").click(function(){ 
      template.remove(); 
      instance.buildConditions();
    });
    
    
    // change value binding
    template.find("input[type='text']").bind("change.fancygrid", function(){
      instance.buildConditions();
    }).bind("focus.fancygrid", function(){
      $(this).select();
    });
  };

  FancygridWrapper.prototype.refresh = function(callback){
    var instance = this;
    var queryData = {};
    queryData.fancygrid = {};
    queryData.fancygrid[instance.name] = instance.query;
    
    instance.queries += 1;
    instance.container.fadeTo(instance.settings.searchFadeTime, instance.settings.searchFadeOpac);
    
    $.ajax({
      type      : instance.settings.ajaxType,
      url       : instance.settings.ajaxUrl,
      data      : queryData,
      dataType  : "html",
      success   : function(result){
        instance.queries -= 1;
        if(instance.queries === 0){
          result = $(result).find("#fancygrid_" + instance.settings.name);

          instance.container.find(".fg-row").detach();
          instance.container.find(".fg-datacontainer").append(result.find(".fg-row"));
          instance.setPage(getValue(result.find(".fg-current-page")));
          instance.setPages(getValue(result.find(".fg-total-pages")));
          instance.container.fadeTo(instance.settings.searchFadeTime, 1.0); 
          instance.container.trigger("ajaxSuccess");
        }
      },
      error : function(){
        instance.queries -= 1;
        if(instance.queries === 0){
          instance.container.find(".fg-row").detach();
          instance.container.fadeTo(instance.settings.searchFadeTime, 1.0); 
          instance.container.trigger("ajaxError");
        }
      },
      complete : callback
    });
  };

  FancygridWrapper.prototype.download = function(type){
    var instance = this;
    var params = {};
    params.fancygrid = {};
    params.fancygrid[instance.name] = instance.query;
    
    var url = instance.settings.ajaxUrl;
    if (url.match(/\.html$/)){
      url = url.substring(0, url.length - 5);
    }
    url = [url, type].join(".");
    
    var data = $.param(params);
    var method = instance.settings.ajaxType;
    
    if( url && data ){ 
      //data can be string of parameters or array/object
      data = (typeof(data) === 'string') ? data : $.param(data);

      //split params into form inputs
      var inputs = '';
      $.each(data.split('&'), function(){ 
        var pair = this.split('=');
        inputs += '<input type="hidden" name="'+ decodeURIComponent(pair[0]) +'" value="'+ decodeURIComponent(pair[1]) +'" />';
      });
      //send request
      $('<form action="'+ url +'" method="'+ (method || 'post') + '">' + inputs + '</form>').appendTo('body').submit().remove();
    }
  };

      
  //
  // jQuery plugin
  //
  
  $.fn.fancygrid = function(options) {
    Fancygrid[options.name] = new FancygridWrapper($(this), options);
    $(this).data("fancygrid", Fancygrid[options.name]);
  };

})(jQuery);