(function(_, angular, d3) {
  var module = angular.module("simulation/graph", []);

  class Graph {
    constructor() {
      this._initSvg();
    }

    draw(data) {
      this.data = data;

      console.info(data);
    }

    _initSvg() {
      this.witdth = 600;
      this.height = 600;
      this.delay  = 250;
      this.svg = d3.select('#simulation-graph svg')
        .attr("viewBox", [0, 0, this.width, this.height]);

      svg.append("g")
        .call(xAxis);

      svg.append("g")
        .call(yAxis);

      this.group = svg.append("g");

      this.rect = group.selectAll("rect");
    }

    _drawGraph() {
      var dx = x.step() * (year - yearMin) / yearStep;

      var t = this.svg.transition()
        .ease(d3.easeLinear)
        .duration(this.delay);

      var x = _x();
      var y = _y();

      var rect = this.rect
        .data(this.data, d => 'infected')
        .join(function(enter) {
          return enter.append("rect")
            .style("mix-blend-mode", "darken")
            .attr("fill", 'red')
            .attr("x", d => x(d.day))
            .attr("y", d => y(0))
            .attr("width", x.bandwidth() + 1)
            .attr("height", 0)
        }, function(update) { 
          return update;
        }, function(exit) {
          return exit.call(function(rect) {
            return rect.transition(t)
              .remove()
              .attr("y", y(0))
              .attr("height", 0))
          }
        });

      rect.transition(t)
        .attr("y", d => y(this._value(d)))
        .attr("height", d => y(0) - y(this._value(d.value)));

      group.transition(t)
        .attr("transform", `translate(${-dx},0)`);
    }

    _x() {
      return d3.scaleBand()
        .domain(Array.from(d3.group(this.data, this._key()).keys()).sort(d3.ascending))
        .range([width - margin.right, margin.left])
    }

    _y() {
      return  d3.scaleLinear()
        .domain([0, d3.max(this.data, this._value())])
        .range([height - margin.bottom, margin.top])
    }

    _value() {
      return (entry =>  entry.infected);
    }

    _key() {
      return (entry =>  entry.day);
    }

    _xAxis() {
      return function(g) {
        return g.attr("transform", `translate(0,${height - margin.bottom})`)
          .call(d3.axisBottom(x)
            .tickValues(d3.ticks(...d3.extent(data, this._key), width / 40))
            .tickSizeOuter(0))
          .call(g => g.append("text")
            .attr("x", margin.right)
            .attr("y", margin.bottom - 4)
            .attr("fill", "currentColor")
            .attr("text-anchor", "end")
            .text(data.x));
      }
    }
  }

  function GraphServiceFactory() {
    return new Graph();
  };

  module.service("simulation_graph", [
    GraphServiceFactory
  ]);
}(window._, window.angular, window.d3));

