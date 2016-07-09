var Modal = React.createClass({
    propTypes: {
        id: React.PropTypes.string.isRequired,
        queryUrl: React.PropTypes.string.isRequired,
        results: React.PropTypes.array,
        selection: React.PropTypes.array,
        resultType: React.PropTypes.string.isRequired,
        handleSave: React.PropTypes.func.isRequired,
        toggleLoading: React.PropTypes.func.isRequired,
        toggleModal: React.PropTypes.func.isRequired,
        toggleModalAndLoading: React.PropTypes.func.isRequired,
        placeholder: React.PropTypes.string,
        input: React.PropTypes.object.isRequired,
        open: React.PropTypes.bool.isRequired,
        addUnmatchedQuery: React.PropTypes.bool,
        resultsFormatter: React.PropTypes.func
    },

    getInitialState: function() {
        return {
            fullField: '',
            fields: this.props.input.fields,
            results: [],
            backspaceTarget: null,
            getResults: _.debounce(this.getResults, 300),
            selection: _.clone(this.props.selection)
        };
    },

    getDefaultProps: function() {
        return {
            minLength: 3,
            changeTargetUp: 38,
            changeTargetDown: 40,
            enterTarget: 13,
            backTarget: 8,
            selection: [],
            addUnmatchedQuery: false
        }
    },

    handleKeyPress: function(event) {
        var change;
        switch(event.keyCode) {
            case this.props.changeTargetUp:
                change = -1;
                break;
            case this.props.changeTargetDown:
                change = 1;
                break;
            case this.props.enterTarget:
                if (this.state.results.length === 0)
                    this.handleSave();
                else
                    this.addToSelection(this.state.scrollTarget);
                    event.preventDefault();
                    return;
            case this.props.backTarget:
                if (this.state.fullField.length === 0)
                    this.handleRemove(event);
                return;
            default:
                return;
        }
        this.setState({ scrollTarget: (this.state.scrollTarget + change) % this.state.results.length });
    },

    handleChange: function(event) {
        var query = event.target.value;
        this.updateFields(query);
    },

    handleAdd: function(event) {
        this.addToSelection(parseInt(event.target.closest('li').getAttribute('data-index')));
    },

    handleRemove: function(event) {
        var backspaceTarget;
        if (Number.isInteger(this.state.backspaceTarget) && this.state.backspaceTarget >= 0) {
            this.removeFromSelection(this.state.backspaceTarget);
            backspaceTarget = this.state.backspaceTarget - 1;
        } else {
            backspaceTarget = this.state.selection.length - 1;
        }

        this.setState({ backspaceTarget: backspaceTarget });
    },

    handleSave: function() {
        this.props.handleSave(this.state.selection);
    },

    handleCancel: function() {
        this.props.toggleModalAndLoading();
        this.setState({
            selection: _.clone(this.props.selection)
        });
    },

    addToSelection: function(index) {
        var fieldValues = this.state.fields.reduce(function(acc, field) {
            if (field.name !== this.props.input.queryField && field.value) {
                acc[field.name] = field.value;
            }
            return acc;
        }.bind(this), {});

        this.setState(
            React.addons.update(
                this.state,
                {
                    selection: {
                        $push: [this.state.results[index]]
                    }
                }
            )
        );

        this.setState({
            backspaceTarget: null,
            scrollTarget: 0,
            results: [],
            fields: this.state.fields.map(function(field) {
                return $.extend(field, {value: null})
            }),
            fullField: ''
        });
    },

    removeFromSelection: function(index) {
        this.setState(
            React.addons.update(
                this.state,
                {
                    selection: {
                        $splice: [[index, 1]]
                    }
                }
            )
        );
    },

    queryValue: function() {
        return this.state.fields.filter(function(field) {
            return field.name === this.props.input.queryField;
        }.bind(this))[0].value;
    },

    updateFields: function(query) {
        var regexString = this.props.input.fields.map(function(field) {
            return field.regex;
        }).reduce(function(acc, regex) {
            return acc + this.props.input.delimiter + regex;
        }.bind(this)) + "$";

        var regex = new RegExp(regexString);
        var fieldValues = regex.exec(query).slice(1, this.state.fields.length + 1);
        var inputFields = this.state.fields.map(function(input, index) {
            return {
                name: input.name,
                regex: input.regex,
                value: fieldValues[index]
            };
        });

        this.setState({
            fullField: query,
            fields: inputFields
        });
    },

    getResults: function() {
        var query = this.queryValue();
        var selected_names = this.state.selection.map(function(selected) {
            return selected.name;
        });

        if (query && query.length >= this.props.minLength) {
            $.getJSON(this.props.queryUrl + query, function(res) {
                var results = this.props.resultsFormatter ? this.props.resultsFormatter(res) : res;

                var displayedResults = results.data.filter(function(result) {
                    return !selected_names.includes(result.name);
                });

                if (this.props.addUnmatchedQuery && displayedResults.length === 0 && !selected_names.includes(query)) {
                    displayedResults.push({
                        name: query,
                        description: 'Add new'
                    });
                }

                this.setState({
                    results: displayedResults,
                    scrollTarget: 0
                });
            }.bind(this));
        } else {
            this.setState({
                results: [],
                scrollTarget: 0
            });
        }
    },

    componentDidUpdate: function(prevProps, prevState) {
        var _this = this;

        if (prevState.fields !== this.state.fields) {
            this.state.getResults();
        }

        if (this.props.open !== prevProps.open) {
            var modal = $('#' + this.props.id);
            if (this.props.open) {
                modal.openModal({
                    ready: function() {
                        _this.refs.search.focus();
                    },
                    complete: function() {
                        _this.handleCancel();
                    }
                });
            } else {
                modal.closeModal();
            }
        }

        if (prevProps.selection !== this.props.selection) {
            this.setState({
                selection: _.clone(this.props.selection)
            });
        }
    },

    render: function() {
        var self = this;
        var resultClass = 'valign-wrapper';
        var pagination;

        var results = this.state.results.map(function(result, index) {
            return React.createElement(this[self.props.resultType], {
                    key: "result-" + index,
                    resultIndex: index,
                    handleAdd: self.handleAdd,
                    result: result,
                    scrollTarget: self.state.scrollTarget
                });
        });
        return (
            <div id={this.props.id} className='modal bottom-sheet'>
                <div className='modal-reveal'>
                    <nav>
                        <div className='nav-wrapper'>
                            <div className='input-field'>
                                <input
                                    placeholder={this.props.input.placeholder}
                                    autoComplete='off'
                                    id='search'
                                    type='search'
                                    ref='search'
                                    value={this.state.fullField}
                                    onKeyDown={this.handleKeyPress}
                                    onChange={this.handleChange}
                                    required />
                                <label htmlFor='search'><i className='material-icons'>search</i></label>
                            </div>
                        </div>
                    </nav>
                    <Multiselect
                        removable={true}
                        ref="selection"
                        selection={this.state.selection}
                        backspaceTarget={this.state.backspaceTarget}
                        removeFromSelection={this.removeFromSelection}/>
                    <ul className='results-container'>
                        {results}
                    </ul>
                    <div className='reveal-controls'>
                        <a
                            className='waves-effect waves-light btn cancel'
                            onClick={this.handleCancel}>
                            <i className='material-icons left'>close</i>
                            Cancel
                        </a>
                        <a
                            className='waves-effect waves-light btn'
                            onClick={this.handleSave}>
                            <i className='material-icons left'>send</i>
                            Update
                        </a>
                    </div>
                </div>
            </div>
        );
    }
});
