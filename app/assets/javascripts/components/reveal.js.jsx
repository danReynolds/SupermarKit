var Reveal = React.createClass({
    propTypes: {
        url: React.PropTypes.string.isRequired
    },

    getInitialState: function() {
        return {
            value: '',
            results: [],
            selection: []
        };
    },

    getDefaultProps: function() {
        return {
            minLength: 3,
            changeTargetUp: 38,
            changeTargetDown: 40,
            enterTarget: 13,
            backTarget: 8
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
        this.addSelected(event.target.getAttribute('data-index'));
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

    handleSave: function(event) {
        var event = new CustomEvent('selection-updated', { detail: this.state.selection });
        document.querySelector('.multiselect').dispatchEvent(event);
    },

    getResults: function(query) {
        if (query.length >= this.props.minLength) {
            $.getJSON(this.props.url + "/?gravatar=true&q=" + query, function(data) {
                results = data.users;
                this.setState({
                    results: data.users,
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
                    data-index={"result-" + index}
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
                <div className='card-reveal-controls'>
                  <a className='btn-floating btn-large waves-effect waves-light card-title cancel'><i className='material-icons'>close</i></a>
                  <a className='btn-floating btn-large waves-effect waves-light card-title' onClick={this.handleSave}><i className='material-icons'>send</i></a>
                </div>
            </div>
        );
    }
});
