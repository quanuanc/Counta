request: `get /income_statement`

response example:
```json
{
  "data": {
    "charts": [
      {
        "data": [
          {
            "account_balances": {},
            "balance": {},
            "budgets": {},
            "date": "2025-12-31"
          }
        ],
        "label": "Net Profit",
        "type": "bar"
      },
      {
        "data": [
          {
            "account_balances": {},
            "balance": {},
            "budgets": {},
            "date": "2025-12-31"
          }
        ],
        "label": "Income (Monthly)",
        "type": "bar"
      },
      {
        "data": [
          {
            "account_balances": {},
            "balance": {},
            "budgets": {},
            "date": "2025-12-31"
          }
        ],
        "label": "Expenses (Monthly)",
        "type": "bar"
      }
    ],
    "date_range": {
      "begin": "2025-12-31",
      "end": "2026-01-01"
    },
    "trees": [
      {
        "account": "Income",
        "balance": {},
        "balance_children": {},
        "children": [
          {
            "account": "Income:US",
            "balance": {},
            "balance_children": {},
            "children": [
              {
                "account": "Income:US:ETrade",
                "balance": {},
                "balance_children": {},
                "children": [
                  {
                    "account": "Income:US:ETrade:Dividends",
                    "balance": {},
                    "balance_children": {},
                    "children": [],
                    "cost": null,
                    "cost_children": null,
                    "has_txns": false
                  },
                  {
                    "account": "Income:US:ETrade:Gains",
                    "balance": {},
                    "balance_children": {},
                    "children": [],
                    "cost": null,
                    "cost_children": null,
                    "has_txns": false
                  }
                ],
                "cost": null,
                "cost_children": null,
                "has_txns": false
              },
              {
                "account": "Income:US:Federal",
                "balance": {},
                "balance_children": {},
                "children": [
                  {
                    "account": "Income:US:Federal:PreTax401k",
                    "balance": {},
                    "balance_children": {},
                    "children": [],
                    "cost": null,
                    "cost_children": null,
                    "has_txns": false
                  }
                ],
                "cost": null,
                "cost_children": null,
                "has_txns": false
              },
              {
                "account": "Income:US:Hoogle",
                "balance": {},
                "balance_children": {},
                "children": [
                  {
                    "account": "Income:US:Hoogle:GroupTermLife",
                    "balance": {},
                    "balance_children": {},
                    "children": [],
                    "cost": null,
                    "cost_children": null,
                    "has_txns": false
                  },
                  {
                    "account": "Income:US:Hoogle:Match401k",
                    "balance": {},
                    "balance_children": {},
                    "children": [],
                    "cost": null,
                    "cost_children": null,
                    "has_txns": false
                  },
                  {
                    "account": "Income:US:Hoogle:Salary",
                    "balance": {},
                    "balance_children": {},
                    "children": [],
                    "cost": null,
                    "cost_children": null,
                    "has_txns": false
                  },
                  {
                    "account": "Income:US:Hoogle:Vacation",
                    "balance": {},
                    "balance_children": {},
                    "children": [],
                    "cost": null,
                    "cost_children": null,
                    "has_txns": false
                  }
                ],
                "cost": null,
                "cost_children": null,
                "has_txns": false
              }
            ],
            "cost": null,
            "cost_children": null,
            "has_txns": false
          }
        ],
        "cost": null,
        "cost_children": null,
        "has_txns": false
      },
      {
        "account": "Net Profit",
        "balance": {},
        "balance_children": {},
        "children": [],
        "cost": null,
        "cost_children": null,
        "has_txns": true
      },
      {
        "account": "Expenses",
        "balance": {},
        "balance_children": {},
        "children": [
          {
            "account": "Expenses:Financial",
            "balance": {},
            "balance_children": {},
            "children": [
              {
                "account": "Expenses:Financial:Commissions",
                "balance": {},
                "balance_children": {},
                "children": [],
                "cost": null,
                "cost_children": null,
                "has_txns": false
              },
              {
                "account": "Expenses:Financial:Fees",
                "balance": {},
                "balance_children": {},
                "children": [],
                "cost": null,
                "cost_children": null,
                "has_txns": false
              }
            ],
            "cost": null,
            "cost_children": null,
            "has_txns": false
          },
          {
            "account": "Expenses:Food",
            "balance": {},
            "balance_children": {},
            "children": [
              {
                "account": "Expenses:Food:Alcohol",
                "balance": {},
                "balance_children": {},
                "children": [],
                "cost": null,
                "cost_children": null,
                "has_txns": false
              },
              {
                "account": "Expenses:Food:Coffee",
                "balance": {},
                "balance_children": {},
                "children": [],
                "cost": null,
                "cost_children": null,
                "has_txns": false
              },
              {
                "account": "Expenses:Food:Groceries",
                "balance": {},
                "balance_children": {},
                "children": [],
                "cost": null,
                "cost_children": null,
                "has_txns": false
              },
              {
                "account": "Expenses:Food:Restaurant",
                "balance": {},
                "balance_children": {},
                "children": [],
                "cost": null,
                "cost_children": null,
                "has_txns": false
              }
            ],
            "cost": null,
            "cost_children": null,
            "has_txns": false
          },
          {
            "account": "Expenses:Health",
            "balance": {},
            "balance_children": {},
            "children": [
              {
                "account": "Expenses:Health:Dental",
                "balance": {},
                "balance_children": {},
                "children": [
                  {
                    "account": "Expenses:Health:Dental:Insurance",
                    "balance": {},
                    "balance_children": {},
                    "children": [],
                    "cost": null,
                    "cost_children": null,
                    "has_txns": false
                  }
                ],
                "cost": null,
                "cost_children": null,
                "has_txns": false
              },
              {
                "account": "Expenses:Health:Life",
                "balance": {},
                "balance_children": {},
                "children": [
                  {
                    "account": "Expenses:Health:Life:GroupTermLife",
                    "balance": {},
                    "balance_children": {},
                    "children": [],
                    "cost": null,
                    "cost_children": null,
                    "has_txns": false
                  }
                ],
                "cost": null,
                "cost_children": null,
                "has_txns": false
              },
              {
                "account": "Expenses:Health:Medical",
                "balance": {},
                "balance_children": {},
                "children": [
                  {
                    "account": "Expenses:Health:Medical:Insurance",
                    "balance": {},
                    "balance_children": {},
                    "children": [],
                    "cost": null,
                    "cost_children": null,
                    "has_txns": false
                  }
                ],
                "cost": null,
                "cost_children": null,
                "has_txns": false
              },
              {
                "account": "Expenses:Health:Vision",
                "balance": {},
                "balance_children": {},
                "children": [
                  {
                    "account": "Expenses:Health:Vision:Insurance",
                    "balance": {},
                    "balance_children": {},
                    "children": [],
                    "cost": null,
                    "cost_children": null,
                    "has_txns": false
                  }
                ],
                "cost": null,
                "cost_children": null,
                "has_txns": false
              }
            ],
            "cost": null,
            "cost_children": null,
            "has_txns": false
          },
          {
            "account": "Expenses:Home",
            "balance": {},
            "balance_children": {},
            "children": [
              {
                "account": "Expenses:Home:Electricity",
                "balance": {},
                "balance_children": {},
                "children": [],
                "cost": null,
                "cost_children": null,
                "has_txns": false
              },
              {
                "account": "Expenses:Home:Internet",
                "balance": {},
                "balance_children": {},
                "children": [],
                "cost": null,
                "cost_children": null,
                "has_txns": false
              },
              {
                "account": "Expenses:Home:Phone",
                "balance": {},
                "balance_children": {},
                "children": [],
                "cost": null,
                "cost_children": null,
                "has_txns": false
              },
              {
                "account": "Expenses:Home:Rent",
                "balance": {},
                "balance_children": {},
                "children": [],
                "cost": null,
                "cost_children": null,
                "has_txns": false
              }
            ],
            "cost": null,
            "cost_children": null,
            "has_txns": false
          },
          {
            "account": "Expenses:Taxes",
            "balance": {},
            "balance_children": {},
            "children": [
              {
                "account": "Expenses:Taxes:Y2015",
                "balance": {},
                "balance_children": {},
                "children": [
                  {
                    "account": "Expenses:Taxes:Y2015:US",
                    "balance": {},
                    "balance_children": {},
                    "children": [
                      {
                        "account": "Expenses:Taxes:Y2015:US:CityNYC",
                        "balance": {},
                        "balance_children": {},
                        "children": [],
                        "cost": null,
                        "cost_children": null,
                        "has_txns": false
                      },
                      {
                        "account": "Expenses:Taxes:Y2015:US:Federal",
                        "balance": {},
                        "balance_children": {},
                        "children": [
                          {
                            "account": "Expenses:Taxes:Y2015:US:Federal:PreTax401k",
                            "balance": {},
                            "balance_children": {},
                            "children": [],
                            "cost": null,
                            "cost_children": null,
                            "has_txns": false
                          }
                        ],
                        "cost": null,
                        "cost_children": null,
                        "has_txns": false
                      },
                      {
                        "account": "Expenses:Taxes:Y2015:US:Medicare",
                        "balance": {},
                        "balance_children": {},
                        "children": [],
                        "cost": null,
                        "cost_children": null,
                        "has_txns": false
                      },
                      {
                        "account": "Expenses:Taxes:Y2015:US:SDI",
                        "balance": {},
                        "balance_children": {},
                        "children": [],
                        "cost": null,
                        "cost_children": null,
                        "has_txns": false
                      },
                      {
                        "account": "Expenses:Taxes:Y2015:US:SocSec",
                        "balance": {},
                        "balance_children": {},
                        "children": [],
                        "cost": null,
                        "cost_children": null,
                        "has_txns": false
                      },
                      {
                        "account": "Expenses:Taxes:Y2015:US:State",
                        "balance": {},
                        "balance_children": {},
                        "children": [],
                        "cost": null,
                        "cost_children": null,
                        "has_txns": false
                      }
                    ],
                    "cost": null,
                    "cost_children": null,
                    "has_txns": false
                  }
                ],
                "cost": null,
                "cost_children": null,
                "has_txns": false
              },
              {
                "account": "Expenses:Taxes:Y2016",
                "balance": {},
                "balance_children": {},
                "children": [
                  {
                    "account": "Expenses:Taxes:Y2016:US",
                    "balance": {},
                    "balance_children": {},
                    "children": [
                      {
                        "account": "Expenses:Taxes:Y2016:US:CityNYC",
                        "balance": {},
                        "balance_children": {},
                        "children": [],
                        "cost": null,
                        "cost_children": null,
                        "has_txns": false
                      },
                      {
                        "account": "Expenses:Taxes:Y2016:US:Federal",
                        "balance": {},
                        "balance_children": {},
                        "children": [
                          {
                            "account": "Expenses:Taxes:Y2016:US:Federal:PreTax401k",
                            "balance": {},
                            "balance_children": {},
                            "children": [],
                            "cost": null,
                            "cost_children": null,
                            "has_txns": false
                          }
                        ],
                        "cost": null,
                        "cost_children": null,
                        "has_txns": false
                      },
                      {
                        "account": "Expenses:Taxes:Y2016:US:Medicare",
                        "balance": {},
                        "balance_children": {},
                        "children": [],
                        "cost": null,
                        "cost_children": null,
                        "has_txns": false
                      },
                      {
                        "account": "Expenses:Taxes:Y2016:US:SDI",
                        "balance": {},
                        "balance_children": {},
                        "children": [],
                        "cost": null,
                        "cost_children": null,
                        "has_txns": false
                      },
                      {
                        "account": "Expenses:Taxes:Y2016:US:SocSec",
                        "balance": {},
                        "balance_children": {},
                        "children": [],
                        "cost": null,
                        "cost_children": null,
                        "has_txns": false
                      },
                      {
                        "account": "Expenses:Taxes:Y2016:US:State",
                        "balance": {},
                        "balance_children": {},
                        "children": [],
                        "cost": null,
                        "cost_children": null,
                        "has_txns": false
                      }
                    ],
                    "cost": null,
                    "cost_children": null,
                    "has_txns": false
                  }
                ],
                "cost": null,
                "cost_children": null,
                "has_txns": false
              },
              {
                "account": "Expenses:Taxes:Y2017",
                "balance": {},
                "balance_children": {},
                "children": [
                  {
                    "account": "Expenses:Taxes:Y2017:US",
                    "balance": {},
                    "balance_children": {},
                    "children": [
                      {
                        "account": "Expenses:Taxes:Y2017:US:CityNYC",
                        "balance": {},
                        "balance_children": {},
                        "children": [],
                        "cost": null,
                        "cost_children": null,
                        "has_txns": false
                      },
                      {
                        "account": "Expenses:Taxes:Y2017:US:Federal",
                        "balance": {},
                        "balance_children": {},
                        "children": [
                          {
                            "account": "Expenses:Taxes:Y2017:US:Federal:PreTax401k",
                            "balance": {},
                            "balance_children": {},
                            "children": [],
                            "cost": null,
                            "cost_children": null,
                            "has_txns": false
                          }
                        ],
                        "cost": null,
                        "cost_children": null,
                        "has_txns": false
                      },
                      {
                        "account": "Expenses:Taxes:Y2017:US:Medicare",
                        "balance": {},
                        "balance_children": {},
                        "children": [],
                        "cost": null,
                        "cost_children": null,
                        "has_txns": false
                      },
                      {
                        "account": "Expenses:Taxes:Y2017:US:SDI",
                        "balance": {},
                        "balance_children": {},
                        "children": [],
                        "cost": null,
                        "cost_children": null,
                        "has_txns": false
                      },
                      {
                        "account": "Expenses:Taxes:Y2017:US:SocSec",
                        "balance": {},
                        "balance_children": {},
                        "children": [],
                        "cost": null,
                        "cost_children": null,
                        "has_txns": false
                      },
                      {
                        "account": "Expenses:Taxes:Y2017:US:State",
                        "balance": {},
                        "balance_children": {},
                        "children": [],
                        "cost": null,
                        "cost_children": null,
                        "has_txns": false
                      }
                    ],
                    "cost": null,
                    "cost_children": null,
                    "has_txns": false
                  }
                ],
                "cost": null,
                "cost_children": null,
                "has_txns": false
              }
            ],
            "cost": null,
            "cost_children": null,
            "has_txns": false
          },
          {
            "account": "Expenses:Transport",
            "balance": {},
            "balance_children": {},
            "children": [
              {
                "account": "Expenses:Transport:Tram",
                "balance": {},
                "balance_children": {},
                "children": [],
                "cost": null,
                "cost_children": null,
                "has_txns": false
              }
            ],
            "cost": null,
            "cost_children": null,
            "has_txns": false
          },
          {
            "account": "Expenses:Vacation",
            "balance": {},
            "balance_children": {},
            "children": [],
            "cost": null,
            "cost_children": null,
            "has_txns": false
          }
        ],
        "cost": null,
        "cost_children": null,
        "has_txns": false
      }
    ]
  },
  "mtime": "0"
}
```
