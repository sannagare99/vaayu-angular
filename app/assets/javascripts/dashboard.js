$(function () {
  if (!$('.micro-dashboard').length) {
    return;
  }

  var red = '#DA4F49',
    blue = '#19A89E',
    dark_blue = '#394264',
    black = '#232332',
    yellow = '#FAB450',
    white = 'white';

  Chart.defaults.global.legend.display = false;
  Chart.defaults.global.layout.padding.bottom = 30;
  Chart.defaults.global.maintainAspectRatio = false;
  Chart.defaults.global.plugins.datalabels.color = 'white';
  Chart.plugins.register({
    beforeDraw: (chart) => {
      if (chart.config.options.elements.center) {
        var ctx = chart.chart.ctx;

        //Get options from the center object in options
        var centerConfig = chart.config.options.elements.center;
        var fontStyle = centerConfig.fontStyle || 'Arial';
        var txt = centerConfig.text;
        var color = centerConfig.color || '#000';
        var sidePadding = centerConfig.sidePadding || 20;
        var sidePaddingCalculated = (sidePadding/100) * (chart.innerRadius * 2);
        //Start with a base font of 30px
        ctx.font = "30px " + fontStyle;

        //Get the width of the string and also the width of the element minus 10 to give it 5px side padding
        var stringWidth = ctx.measureText(txt).width;
        var elementWidth = (chart.innerRadius * 2) - sidePaddingCalculated;

        // Find out how much the font can grow in width.
        var widthRatio = elementWidth / stringWidth;
        var newFontSize = Math.floor(30 * widthRatio);
        var elementHeight = (chart.innerRadius * 2);

        // Pick a new font size so it will not be larger than the height of label.
        var fontSizeToUse = Math.min(newFontSize, elementHeight);

        //Set font settings to draw it correctly.
        ctx.textAlign = 'center';
        ctx.textBaseline = 'middle';
        var centerX = ((chart.chartArea.left + chart.chartArea.right) / 2);
        var centerY = ((chart.chartArea.top + chart.chartArea.bottom) / 2);
        ctx.font = fontSizeToUse+"px " + fontStyle;
        ctx.fillStyle = color;

        //Draw text in center
        ctx.fillText(txt, centerX, centerY);
      }
    }
  });
  Chart.plugins.register({
    afterDraw: (chart) => {
      if (chart.config.options.plugins.roundedCorners) {
        var ctx = chart.chart.ctx;
        chart.data.datasets.forEach((dataset) => {
          var arc = dataset._meta[Object.keys(dataset._meta)[0]].data[1];
          var startAngle = Math.PI/2 - arc._view.startAngle - Math.PI/300;
          var endAngle = Math.PI/2 - arc._view.endAngle + Math.PI/300;
          var centerX = (arc._chart.chartArea.left + arc._chart.chartArea.right)/2;
          var centerY = (arc._chart.chartArea.top + arc._chart.chartArea.bottom)/2;
          var radius = (arc._view.outerRadius + arc._view.innerRadius + Math.pow(arc._datasetIndex,2) - arc._datasetIndex*2.5)/2;
          var thickness = (arc._view.outerRadius - arc._view.innerRadius - arc._datasetIndex*1.5 + 2)/2;

          ctx.save();
          ctx.translate(centerX, centerY);
          ctx.beginPath();
          ctx.arc(radius*Math.sin(startAngle), radius*Math.cos(startAngle), thickness, 0, 2*Math.PI, false);
          ctx.arc(radius*Math.sin(endAngle), radius*Math.cos(endAngle), thickness, 0, 2*Math.PI, false);
          ctx.closePath();
          ctx.fillStyle = arc._model.backgroundColor;
          ctx.fill();
          ctx.restore();
        });
      }
    }
  });

  function convert_to_bar_data(stats) {
    return Object.keys(stats).map((k) => {
      return stats[k];
    });
  }

  function get_stacked_data(data, key) {
    return Object.keys(data).map((k) => {
      return data[k][key] || 0;
    });
  }

  function get_grouped_stacked_data(data, key) {
    return Object.keys(data).map((k) => {
      var _k = JSON.parse(k);
      if (_k[0] === key) {
        return data[k] || 0;
      }
      return 0;
    });
  }

  function get_multi_group_data(data, labelMap) {
    var by_shift = {};
    var colors = [dark_blue, blue, yellow, red, black];
    Object.keys(data).forEach((k) => {
      var key = JSON.parse(k);
      if (!by_shift[key[1]]) {
        by_shift[key[1]] = {};
      }
      by_shift[key[1]][key[0]] = data[k];
    });
    var ds = {};
    Object.keys(by_shift).forEach((k) => {
      if (labelMap) {
        Object.keys(labelMap).forEach((kk) => {
          var key = labelMap[kk];
          if (!ds[key]) {
            ds[key] = [];
          }
          ds[key].push(by_shift[k][kk] || 0);
        });
      } else {
        Object.keys(by_shift[k]).forEach((kk) => {
          if (!ds[kk]) {
            ds[kk] = [];
          }
          ds[kk].push(by_shift[k][kk])
        });
      }
    });
    var datasets = Object.keys(ds).map((k, i) => {
      return {
        label: k,
        data: ds[k],
        backgroundColor: colors[i],
      };
    });
    return {
      datasets: datasets,
      labels: Object.keys(by_shift)
    };
  }

  function renderTrendChart(selector) {
    var data = $(selector).data('chart_data');
    new Chart($(selector), {
      type: 'bar',
      data: {
        datasets: [{
          label: 'To Home',
          data: convert_to_bar_data(data['to_home']),
          borderColor: blue,
          backgroundColor: blue,
        }, {
          label: 'To Work',
          data: convert_to_bar_data(data['to_work']),
          borderColor: dark_blue,
          backgroundColor: dark_blue,
        }, {
          label: 'Total',
          data: convert_to_bar_data(data['total']),
          type: 'line',
          fill: false,
          lineTension: 0,
          borderColor: black,
          backgroundColor: black,
          pointBorderColor: black,
          pointBackgroundColor: black,
          datalabels: {
            display: false
          }
        }],
        labels: Object.keys(data['total'])
      },
      options: {
        scales: {
          yAxes: [{
            scaleLabel: {
              display: true,
              labelString: '(Trips)',
            },
            ticks: {
              beginAtZero: true
            }
          }],
          xAxes: [{
            gridLines: {
              display: false
            },
            barPercentage: 0.9,
          }]
        }
      }
    });
  }

  var exceptionLabelMap = {
    'not_on_board': 'Not On Board',
    'still_on_board': 'Still On Board',
    'panic': 'Panic Alerts',
    'employee_no_show': 'Employee No Show',
    'driver_no_show': 'Driver No Show',
  };

  if ($('.micro-dashboard.completed-trips').length) {
    renderTrendChart('#completed-trips-trend');

    function renderBreakupChart(selector, centerLabel) {
      var completed_trips_breakup = $(selector);
      var data = completed_trips_breakup.data('chart_data');
      new Chart(completed_trips_breakup, {
        type: 'doughnut',
        data: {
          datasets: [{
            label: 'All Good',
            data: [
              data['total'] - data['all_good'],
              data['all_good'],
            ],
            borderColor: ['white', blue],
            backgroundColor: ['white', blue]
          }, {
            label: 'With Exceptions',
            data: [
              data['total'] - data['with_exceptions'],
              data['with_exceptions'],
            ],
            borderColor: ['white', red],
            backgroundColor: ['white', red]
          }, {
            label: 'OLA/Uber',
            data: [
              data['total'] - data['ola_uber'],
              data['ola_uber'],
            ],
            borderColor: ['white', yellow],
            backgroundColor: ['white', yellow]
          }],
          labels: ['All Good', 'With Exceptions', 'OLA / Uber', '']
        },
        options: {
          cutoutPercentage: 70,
          elements: {
            center: {
              text: centerLabel + " " + data['total'],
              color: dark_blue,
            }
          },
          tooltips: {
            enabled: false,
          },
          plugins: {
            datalabels: {
              align: 'right',
              anchor: 'center',
              color: dark_blue,
              formatter: (value, context) => {
                if (context.dataIndex === 1) {
                  return value;
                }
                return '';
              }
            },
            roundedCorners: true
          },
        }
      });
    }
    renderBreakupChart('#completed-trips-breakup-total', 'Total');
    renderBreakupChart('#completed-trips-breakup-work', 'To Work');
    renderBreakupChart('#completed-trips-breakup-home', 'To Home');

    var completed_trips_esummary = $('#completed-trips-exceptions-summary');
    data = completed_trips_esummary.data('chart_data');
    new Chart(completed_trips_esummary, {
      type: 'horizontalBar',
      data: {
        datasets: [{
          label: 'Driver',
          data: get_stacked_data(data, 'driver_no_show'),
          backgroundColor: dark_blue,
        }, {
          label: 'Employee',
          data: get_stacked_data(data, 'employee_no_show'),
          backgroundColor: blue,
        }, {
          label: 'Vehicle',
          data: get_stacked_data(data, 'still_on_board'),
          backgroundColor: yellow,
        }, {
          label: 'Technical',
          data: get_stacked_data(data, 'panic'),
          backgroundColor: red,
        }],
        labels: ['Total', 'To Work', 'To Home'],
      },
      options: {
        scales: {
          xAxes: [{
            scaleLabel: {
              display: true,
              labelString: '(Count)',
              fontSize: 10,
              fontColor: '#ccc'
            },
            stacked: true,
            ticks: {
              beginAtZero: true
            },
          }],
          yAxes: [{
            stacked: true,
            gridLines: {
              display: false
            },
            barPercentage: 0.6,
          }]
        }
      }
    });

    var completed_trips_fulfillment = $('#completed-trips-fulfillment');
    data = completed_trips_fulfillment.data('chart_data');
    new Chart(completed_trips_fulfillment, {
      type: 'doughnut',
      data: {
        datasets: [{
          data: [
            data['scheduled'],
            data['transported'],
            data['cancelled'],
            data['no_shows'],
          ],
          borderColor: [dark_blue, blue, yellow, red],
          backgroundColor: [dark_blue, blue, yellow, red],
        }],
        labels: ['Scheduled + Change', 'Transported', 'Cancelled', 'No Shows']
      },
      options: {
        cutoutPercentage: 70,
        // rotation: -2.5 * Math.PI,
        elements: {
          center: {
            text: "Total"
          }
        },
      }
    });

    var completed_trips_overall_mileage = $('#completed-trips-overall-mileage');
    data = completed_trips_overall_mileage.data('chart_data');
    new Chart(completed_trips_overall_mileage, {
      type: 'horizontalBar',
      data: {
        datasets: [{
          label: 'With Employees',
          data: get_stacked_data(data, 'with_employees'),
          backgroundColor: dark_blue
        }, {
          label: 'Without Employees',
          data: get_stacked_data(data, 'without_employees'),
          backgroundColor: blue,
        }],
        labels: ['Overall', 'To Work', 'To Home']
      },
      options: {
        scales: {
          xAxes: [{
            stacked: true,
            ticks: {
              beginAtZero: true
            },
          }],
          yAxes: [{
            stacked: true,
            gridLines: {
              display: false
            },
            barPercentage: 0.6,
          }]
        }
      }
    });

    function renderAveragePieChart(selector) {
      var data = $(selector).data('chart_data');
      new Chart($(selector), {
        type: 'pie',
        data: {
          datasets: [{
            data: [
              data['to_work'],
              data['to_home']
            ],
            backgroundColor: [dark_blue, blue],
          }],
          labels: ['To Work', 'To Home']
        },
        options: {
        }
      });
    }
    renderAveragePieChart('#completed-trips-average-mileage');
    renderAveragePieChart('#completed-trips-average-duration');
    renderAveragePieChart('#completed-trips-distance-per-employee');
    renderAveragePieChart('#completed-trips-duration-per-employee');

    function renderMoreCharts(selector) {
      var data = $(selector).data('chart_data');
      new Chart($(selector), {
        type: 'horizontalBar',
        data: {
          datasets: [{
            data: Object.keys(data).map((k) => data[k]),
            backgroundColor: dark_blue
          }],
          labels: Object.keys(data)
        },
        options: {
          scales: {
            xAxes: [{
              scaleLabel: {
                display: true,
                labelString: '(trips)',
                fontSize: 10,
                fontColor: '#777'
              },
              ticks: {
                beginAtZero: true
              }
            }],
            yAxes: [{
              gridLines: {
                display: false
              },
              barPercentage: 0.8,
            }]
          }
        }
      });
    }
    renderMoreCharts('#completed-trips-by-shift');
    renderMoreCharts('#completed-trips-by-vehicle');
    renderMoreCharts('#completed-trips-by-site');
  } else if ($('.micro-dashboard.ota').length) {
    function renderOtaTrend(selector) {
      var data = $(selector).data('chart_data');
      new Chart($(selector), {
        type: 'bar',
        data: {
          datasets: [{
            label: 'OTA',
            data: convert_to_bar_data(data['ota']),
            type: 'line',
            fill: false,
            borderColor: blue,
            lineTension: 0,
            pointBorderColor: blue,
            pointBackgroundColor: white,
            datalabels: {
              display: false
            }
          }, {
            label: 'Total Login Trips',
            data: convert_to_bar_data(data['total']),
            borderColor: dark_blue,
            backgroundColor: dark_blue,
          }],
          labels: Object.keys(data['total'])
        },
        options: {
          scales: {
            yAxes: [{
              scaleLabel: {
                display: true,
                labelString: '(Trips)',
              },
              ticks: {
                beginAtZero: true
              }
            }],
            xAxes: [{
              gridLines: {
                display: false
              },
              barPercentage: 0.8,
            }]
          }
        }
      });
    }
    renderOtaTrend('#ota-trend-arrivals');
    renderOtaTrend('#ota-trend-departures');
  } else if ($('.micro-dashboard.exceptions').length) {
    renderTrendChart('#exceptions-trend');

    var exceptions_breakup = $('#exceptions-breakup');
    var data = exceptions_breakup.data('chart_data');
    new Chart(exceptions_breakup, {
      type: 'horizontalBar',
      data: {
        datasets: [{
          label: 'Panic Alerts',
          data: Object.keys(data).map((k) => data[k]),
          backgroundColor: dark_blue,
        }],
        labels: Object.keys(data).map((k) => exceptionLabelMap[k])
      },
      options: {
        scales: {
          xAxes: [{
            scaleLabel: {
              display: true,
              labelString: '(Count)',
              fontSize: 10,
              fontColor: '#777',
            },
            ticks: {
              beginAtZero: true
            }
          }],
          yAxes: [{
            gridLines: {
              display: false
            },
            barPercentage: 0.9,
          }]
        }
      }
    });

    var exceptions_shift_wise = $('#exceptions-shift-wise');
    data = exceptions_shift_wise.data('chart_data');
    new Chart(exceptions_shift_wise, {
      type: 'horizontalBar',
      data: get_multi_group_data(data, exceptionLabelMap),
      // data: {
      //   datasets: [{
      //     label: 'Panic',
      //     data: get_grouped_stacked_data(data, 'panic'),
      //     backgroundColor: dark_blue,
      //   }, {
      //     label: 'Still On Board',
      //     data: get_grouped_stacked_data(data, 'still_on_board'),
      //     backgroundColor: blue,
      //   }, {
      //     label: 'Not On board',
      //     data: get_grouped_stacked_data(data, 'not_on_board'),
      //     backgroundColor: yellow,
      //   }, {
      //     label: 'Driver No Show',
      //     data: get_grouped_stacked_data(data, 'driver_no_show'),
      //     backgroundColor: red,
      //   }, {
      //     label: 'Employee No Show',
      //     data: get_grouped_stacked_data(data, 'employee_no_show'),
      //     backgroundColor: black,
      //   }],
      //   labels: Object.keys(data).map((k) => JSON.parse(k)[1])
      // },
      options: {
        scales: {
          xAxes: [{
            scaleLabel: {
              display: true,
              labelString: '(Count)',
              fontSize: 10,
              fontColor: '#777',
            },
            stacked: true,
            ticks: {
              beginAtZero: true
            },
          }],
          yAxes: [{
            stacked: true,
            gridLines: {
              display: false
            },
            barPercentage: 0.6,
          }]
        }
      }
    });
  } else if ($('.micro-dashboard.fleet-utilization').length) {
    var fleet_utilization_operator = $('#fleet-utilization-operator-wise');
    data = fleet_utilization_operator.data('chart_data');
    new Chart(fleet_utilization_operator, {
      type: 'horizontalBar',
      data: get_multi_group_data(data),
      options: {
        scales: {
          xAxes: [{
            scaleLabel: {
              display: true,
              labelString: '(Count)',
              fontSize: 10,
              fontColor: '#777'
            },
            stacked: true,
            ticks: {
              beginAtZero: true
            },
          }],
          yAxes: [{
            stacked: true,
            gridLines: {
              display: false
            },
            barPercentage: 0.7,
          }]
        }
      }
    });

    function get_load_factor_data(data) {
      var by_shift = {};
      var colors = [dark_blue, blue, yellow, red, black];
      data.forEach((d) => {
        var key = d['shift'];
        if (!by_shift[key]) {
          by_shift[key] = [];
        }
        by_shift[key].push({
          user_name: d['user_name'],
          util_perc: d['util_perc']
        });
      });
      var ds = {};
      Object.keys(by_shift).forEach((k) => {
        by_shift[k].forEach((kk) => {
          var key = kk['user_name'];
          if (!ds[key]) {
            ds[key] = [];
          }
          ds[key].push(kk['util_perc']);
        });
      });
      var datasets = Object.keys(ds).map((k, i) => {
        return {
          label: k,
          data: ds[k],
          backgroundColor: colors[i],
        };
      });
      return {
        datasets: datasets,
        labels: Object.keys(by_shift)
      };
    }

    var fleet_utilization_load_factor = $('#fleet-utilization-load-factor');
    data = fleet_utilization_load_factor.data('chart_data');
    new Chart(fleet_utilization_load_factor, {
      type: 'horizontalBar',
      data: get_load_factor_data(data),
      options: {
        scales: {
          xAxes: [{
            scaleLabel: {
              display: true,
              labelString: '(Count)',
              fontSize: 10,
              fontColor: '#777'
            },
            stacked: true,
            ticks: {
              beginAtZero: true
            },
          }],
          yAxes: [{
            stacked: true,
            gridLines: {
              display: false
            },
            barPercentage: 0.7,
          }]
        }
      }
    });
  }
});
