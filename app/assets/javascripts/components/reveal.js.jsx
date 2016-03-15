var Reveal = React.createClass({
    propTypes: {
        id: React.PropTypes.string.isRequired,
        queryUrl: React.PropTypes.string.isRequired,
        results: React.PropTypes.array,
        selection: React.PropTypes.array,
        type: React.PropTypes.string.isRequired,
        addToSelection: React.PropTypes.func.isRequired,
        removeFromSelection: React.PropTypes.func.isRequired,
        handleSave: React.PropTypes.func.isRequired,
        toggleModal: React.PropTypes.func.isRequired,
        placeholder: React.PropTypes.string,
        input: React.PropTypes.object.isRequired,
        modalOpen: React.PropTypes.bool.isRequired
    },

    getInitialState: function() {
        return {
            fullField: '',
            fields: this.props.input.fields,
            results: [],
            backspaceTarget: null
        };
    },

    getDefaultProps: function() {
        return {
            minLength: 3,
            changeTargetUp: 38,
            changeTargetDown: 40,
            enterTarget: 13,
            backTarget: 8,
            selection: []
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
        this.addToSelection(parseInt(event.target.getAttribute('data-index')));
    },

    handleRemove: function(event) {
        var backspaceTarget;
        if (Number.isInteger(this.state.backspaceTarget) && this.state.backspaceTarget >= 0) {
            this.props.removeFromSelection(this.state.backspaceTarget);
            backspaceTarget = this.state.backspaceTarget - 1;
        } else {
            backspaceTarget = this.props.selection.length - 1;
        }

        this.setState({ backspaceTarget: backspaceTarget });
    },

    handleSave: function() {
        this.props.toggleModal();
        this.props.handleSave();
    },

    addToSelection: function(index) {
        var fieldValues = this.state.fields.reduce(function(acc, field) {
            if (field.name !== this.props.input.queryField && field.value) {
                acc[field.name] = field.value;
            }
            return acc;
        }.bind(this), {});

        this.setState({
            backspaceTarget: null,
            scrollTarget: 0,
            results: [],
            fields: this.state.fields.map(function(field) {
                return $.extend(field, {value: null})
            }),
            fullField: ''
        });

        this.props.addToSelection(
            React.addons.update(this.state.results[index], {$merge: fieldValues})
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
        var selected_ids = this.props.selection.map(function(selected) {
            return selected.id;
        });

        if (query && query.length >= this.props.minLength) {
            $.getJSON(this.props.queryUrl + query, function(results) {
                this.setState({
                    results: results.filter(function(user) {
                        return !selected_ids.includes(user.id);
                    }),
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
        var self = this;

        if (prevState.fields !== this.state.fields) {
            this.getResults();
        } else if (this.props.modalOpen !== prevProps.modalOpen) {
            var modal = $('#' + this.props.id);
            if (this.props.modalOpen) {
                modal.openModal({
                    ready: function() {
                        self.refs.search.focus();
                    }
                });
            } else {
                modal.closeModal();
            }
        }
    },

    render: function() {
        var self = this;
        var resultClass = 'valign-wrapper';

        var results = this.state.results.map(function(result, index) {
            return (
                React.createElement(this[self.props.type], {
                    key: "result-" + index,
                    resultIndex: index,
                    handleAdd: self.handleAdd,
                    result: result,
                    scrollTarget: self.state.scrollTarget
                })
            );
        });

        return (
            <div id={this.props.id} className='modal bottom-sheet'>
                <div className='reveal'>
                    <nav>
                        <div className='nav-wrapper'>
                            <form>
                                <div className='input-field'>
                                    <input
                                        placeholder={this.props.placeholder}
                                        autoComplete='off'
                                        id='search'
                                        type='search'
                                        ref='search'
                                        value={this.state.fullField}
                                        onKeyDown={this.handleKeyPress}
                                        onChange={this.handleChange}
                                        required />
                                    <label htmlFor='search'><i className='material-icons'>search</i></label>
                                    <i className='material-icons'>close</i>
                              </div>
                            </form>
                        </div>
                    </nav>
                    <Multiselect
                        ref="selection"
                        placeholder={this.props.placeholder}
                        selection={this.props.selection}
                        backspaceTarget={this.state.backspaceTarget}
                        removeFromSelection={this.props.removeFromSelection}/>
                    <ul className='results-container'>
                        {results}
                    </ul>
                    <div className='reveal-controls'>
                        <a
                            ref='open'
                            className='waves-effect waves-light btn cancel'
                            onClick={this.props.toggleModal}>
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
