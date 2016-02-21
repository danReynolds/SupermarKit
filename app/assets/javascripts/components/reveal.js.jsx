var Reveal = React.createClass({
    propTypes: {
        modal: React.PropTypes.string.isRequired,
        queryUrl: React.PropTypes.string.isRequired,
        results: React.PropTypes.array,
        selection: React.PropTypes.array,
        type: React.PropTypes.string.isRequired
    },

    getInitialState: function() {
        return {
            value: '',
            results: [],
            selection: this.props.selection
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
                this.handleRemove(event);
                return;
            default:
                return;
        }
        this.setState({ scrollTarget: (this.state.scrollTarget + change) % this.state.results.length });
    },

    handleChange: function(event) {
        var query = event.target.value;
        this.setState({ value: query });
        this.getResults(query);
    },

    handleAdd: function(event) {
        this.addToSelection(parseInt(event.target.getAttribute('data-index')));
    },

    handleRemove: function(event) {
        if (this.state.value.length !== 0) return;

        var selection = this.state.selection;

        if (Number.isInteger(this.state.backspaceTarget) && this.state.backspaceTarget >= 0) {
            selection = React.addons.update(selection, {$splice: [[this.state.backspaceTarget, 1]]});
        }

        this.setState({
            backspaceTarget: selection.length - 1,
            selection: selection
        });
    },

    handleSave: function() {
        $(this.props.modal).closeModal();
        this.dispatchSelection();
    },

    addToSelection: function(index) {
        this.setState({
            backspaceTarget: null,
            scrollTarget: 0,
            selection: this.state.selection.concat(this.state.results[index])
        });
    },

    removeFromSelection: function(index) {
        this.setState({
            backspaceTarget: null,
            selection: React.addons.update(this.state.selection, {$splice: [[index, 1]]})
        });
    },

    dispatchSelection: function() {
        var event = new CustomEvent('selection-updated', { detail: this.state.selection });
        document.querySelector('.multiselect').dispatchEvent(event);
    },

    getResults: function(query) {
        var selected_ids = this.state.selection.map(function(selected) {
            return selected.id;
        });

        if (query.length >= this.props.minLength) {
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

    componentDidMount: function() {
        var self = this;
        $(document).ready(function() {
            $('.modal-trigger').leanModal({
                ready: function() {
                    ReactDOM.findDOMNode(self.refs.search).focus();
                }
            });
            self.dispatchSelection();
        });
    },

    render: function() {
        var self = this;
        var resultClass = 'valign-wrapper';

        var results = this.state.results.filter(function(result) {
            return !self.state.selection.map(function(result) {
                return result.id;
            }).includes(result.id);
        }).map(function(result, index) {
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
            <div className='reveal'>
                <nav>
                    <div className='nav-wrapper'>
                        <form>
                            <div className='input-field'>
                                <input
                                    autoComplete='off'
                                    id='search'
                                    type='search'
                                    ref='search'
                                    value={this.state.value}
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
                    selection={this.state.selection}
                    backspaceTarget={this.state.backspaceTarget}
                    removeFromSelection={this.removeFromSelection}/>
                <ul className='results-container'>
                    {results}
                </ul>
                <div className='reveal-controls'>
                    <a className='waves-effect waves-light btn cancel modal-close'><i className='material-icons left'>close</i>Cancel</a>
                    <a className='waves-effect waves-light btn' onClick={this.handleSave}><i className='material-icons left'>send</i>Update</a>
                </div>
            </div>
        );
    }
});
