(function(){
  var IPGeolocation = Backbone.Model.extend({
    urlRoot: 'http://' + document.location.host + '/api/lookup',
    parse: function(response, options){
      return response.geolocation[0];
    }
  });

  var IPGeolocationCollecton = Backbone.Collection.extend({
    model: IPGeolocation
  });

  var AddressList =  Backbone.View.extend({
    template: _.template("<% collection.each(function(ip) { %> <li><%= ip.id %></li> <% }); %>"),

    initialize: function(options) {
      this.listenTo(options.collection, "add", _.bind(this.render, this));
    },

    render: function(){
      var src = this.template({collection: this.options.collection});
      this.$el.html(src);
    }
  });

  var NewAddressForm = Backbone.View.extend({
    SAMPLE_IPS: ['98.251.52.1', '68.85.173.249', '68.85.109.77'],
    inputId: "ip-address",

    events: {
      'click .add': 'addIP',
      'click .sample': 'addSamples',
      'submit': function(){ return false; }
    },

    initialize: function() {
      _.bindAll(this, 'addIP', 'addSamples');

      this.input = document.getElementById(this.inputId);
    },

    addIP: function() {
      var ip = this.input.value;
      this.input.value = "";
      this._addIP(ip);
    },

    addSamples: function(){
      var i = 0, ip;

      for (; ip = this.SAMPLE_IPS[i]; i++) {
        this._addIP(ip);
      }
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

  var IPMap = function(mapId) {
    this.map = new google.maps.Map(document.getElementById(mapId), {
      center: new google.maps.LatLng(33.98, -83.69),
      zoom: 5,
      mapTypeId: google.maps.MapTypeId.ROADMAP,
      maxZoom: 18
    });

    this.mapBounds = new google.maps.LatLngBounds();
  };

  IPMap.prototype.addIP = function(model){
    var lat = model.get('latitude'),
        lng = model.get('longitude'),
        coord, marker;

    if (lat && lng) {
      coord = new google.maps.LatLng(lat, lng);
      this.mapBounds.extend(coord);
      this.map.fitBounds(this.mapBounds);

      marker = new google.maps.Marker({
        position: coord,
        map: this.map,
        title: "IP: " + model.id
      });
    }
  };

  // Initialize
  var addressCollection = new IPGeolocationCollecton();

  var addressList = new AddressList({
    el: document.getElementById('address-list'),
    collection: addressCollection
  });

  var newAddress = new NewAddressForm({
    el: document.getElementById('new-address'),
    collection: addressCollection
  });

  var ipMap = new IPMap('map-canvas');
  addressCollection.on("add", ipMap.addIP, ipMap);
}());
