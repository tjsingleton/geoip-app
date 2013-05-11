(function(){
  var IPGeolocation = Backbone.Model.extend({
    urlRoot: 'http://' + document.location.host + '/api/lookup',

    parse: function(response, options){
      return response.geolocation[0];
    },

    locationStr: function(){
      return _([
        this.get('city_name'),
        this.get('region_name'),
        this.get('country_code2')
      ]).reject(function(n){ return _.isEmpty(n); }).join(', ');
    }
  });

  var IPGeolocationCollecton = Backbone.Collection.extend({
    model: IPGeolocation
  });

  var AddressListItem =  Backbone.View.extend({
    template: _.template('<%= model.id %> (<%= model.locationStr() %>)'),
    events: {
      'click': 'showDetail'
    },

    render: function(){
      this.$el.html(this.template({model: this.model}));

      return this;
    },

    showDetail: function(){
      Backbone.trigger('ip:detail', this.model)
    }
  });

  var NewAddressForm = Backbone.View.extend({
    SAMPLE_IPS: ['98.251.52.1', '68.85.173.249', '68.85.109.77'],
    inputId: "ip-address",

    events: {
      'click .add': 'addIP',
      'click .sample': 'addSamples',
      'submit': 'addIP'
    },

    initialize: function() {
      _.bindAll(this, 'addIP', 'addSamples');

      this.input = document.getElementById(this.inputId);
    },

    addIP: function() {
      var ip = this.input.value;
      this.input.value = "";
      console.log(ip);
      this._addIP(ip);

      return false;
    },

    addSamples: function(){
      var i = 0, ip;

      for (; ip = this.SAMPLE_IPS[i]; i++) {
        this._addIP(ip);
      }

      return false;
    },

    _addIP: function(ip) {
      var model = new IPGeolocation({id: ip}),
          collection = this.options.collection;

      model.fetch({
        success: function(){
          collection.add(model);
        },

        error: function(){
          alert("Could not add ip " + model.id +". Are you sure it's valid?");
        }
      });
    }
  });

  var IPMap = function(el) {
    this.map = new google.maps.Map(el, {
      center: new google.maps.LatLng(33.98, -83.69),
      zoom: 5,
      mapTypeId: google.maps.MapTypeId.ROADMAP,
      maxZoom: 18
    });

    this.mapBounds = new google.maps.LatLngBounds();
    this.data = {};
  };

  _.extend(IPMap.prototype, {
    template: _.template('<div class="info">' +
                         '<h3><%= model.id %></h3>' +
                         '<% _.each(model.attributes, function(value, key){ %>' +
                         '<% if (value === model.id || !value) { return; } %>' +
                         '<div><strong><%= key %>:</strong> <%= value %>' +
                         '<% }); %>'+
                         '</div>'),

    addMarker: function(model){
      var lat = model.get('latitude'),
          lng = model.get('longitude'),
          coord, marker, infoWindow;

      if (!lat || !lng) { return; }
      coord = new google.maps.LatLng(lat, lng);

      this.mapBounds.extend(coord);
      this.map.fitBounds(this.mapBounds);

      marker = new google.maps.Marker({
        position: coord,
        map: this.map
      });

      infoWindow = new google.maps.InfoWindow({
        content: this.template({model: model})
      });

      this.data[model.id] = {
        model: model,
        marker: marker,
        infoWindow: infoWindow
      };

      marker.addListener('click', _.bind(function(){
        this.showDetail(model);
      }, this));
    },

    showDetail: function(model) {
      _(this.data).each(function(item, id){
        if (id == model.id) {
          item.infoWindow.open(this.map, item.marker);
        } else {
          item.infoWindow.close();
        }
      }, this);
    }
  });


  // Initialize
  var addressCollection = new IPGeolocationCollecton();

  var newAddress = new NewAddressForm({
    el: document.getElementById('new-address'),
    collection: addressCollection
  });

  var ipMap = new IPMap(document.getElementById('map-canvas'));
  var list = document.getElementById('address-list');

  addressCollection.on("add", function(model){
    var listItem;

    ipMap.addMarker(model);

    listItem = new AddressListItem({
      tagName: 'li',
      model: model
    });
    list.appendChild(listItem.render().el);
  });

  Backbone.on("ip:detail", function(model){
    ipMap.showDetail(model);
  });
}());
