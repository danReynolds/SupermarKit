var Reveal = React.createClass({
    propTypes: {
        url: React.PropTypes.string.isRequired,
        modal: React.PropTypes.string.isRequired,
        selection: React.PropTypes.array
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
                    this.addSelected(this.state.scrollTarget);
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
        this.addSelected(parseInt(event.target.getAttribute('data-index')));
    },

    addSelected: function(index) {
        this.setState({
            backspaceTarget: null,
            scrollTarget: 0,
            selection: this.state.selection.concat(this.state.results[index]),
            results: React.addons.update(this.state.results, {$splice: [[index, 1]]})
        });
    },

    removeSelection: function(index) {
        this.setState({
            backspaceTarget: null,
            selection: React.addons.update(this.state.selection, {$splice: [[index, 1]]})
        });
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

    dispatchSelection: function() {
        var event = new CustomEvent('selection-updated', { detail: this.state.selection });
        document.querySelector('.multiselect').dispatchEvent(event);
    },

    getResults: function(query) {
        var user_ids = this.state.selection.map(function(selected) {
            return selected.id;
        });

        if (query.length >= this.props.minLength) {
            $.getJSON(this.props.url + "/?gravatar=true&q=" + query, function(data) {
                results = data.users;
                this.setState({
                    results: data.users.filter(function(user) {
                        return !user_ids.includes(user.id);
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
        $(document).ready(function() {
            this.dispatchSelection();
        }.bind(this));
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
                <li
                    className={index == self.state.scrollTarget ? resultClass + ' target' : resultClass}
                    onClick={self.handleAdd}
                    data-index={index}
                    key={"result-" + result.id}>
                    <img src={result.gravatar}/>
                    <p>{result.name}</p>
                </li>
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
                                onChange={this.handleChange}
                                onKeyDown={this.handleKeyPress}
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
                    removeSelection={this.removeSelection}/>
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
