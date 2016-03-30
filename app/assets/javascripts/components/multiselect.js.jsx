var Multiselect = React.createClass({
    propTypes: {
        title: React.PropTypes.string,
        button: React.PropTypes.string,
        selection: React.PropTypes.array,
        removeFromSelection: React.PropTypes.func,
        hiddenField: React.PropTypes.string,
        modal: React.PropTypes.object,
        backspaceTarget: React.PropTypes.number
    },

    getDefaultProps: function() {
        return {
            selection: []
        }
    },

    handleRemove: function(event) {
        this.props.removeFromSelection(parseInt(event.target.closest('.chip').getAttribute('data-id')));
    },

    render: function() {
        var button, title, remove, modal, image;

        if (this.props.image) {
            image = <img src={selected.image} />;
        }

        if (this.props.title) {
            title = <h3>{this.props.title}</h3>;
        }

        if (this.props.removeFromSelection) {
            remove = <i className='fa fa-close' onClick={this.handleRemove}/>;
        }

        var selection = this.props.selection.map(function(selected, index) {
            return (
                <div
                    className={this.props.backspaceTarget === index ? 'chip targetted' : 'chip'}
                    data-id={index}
                    key={'selection-' + index} >
                    {image}
                    {selected.name}
                    {remove}
                </div>
            );
        }.bind(this));

        return (
            <div className='multiselect' ref='root'>
                {title}
                <div className='selection-container valign-wrapper'>
                    {selection}
                </div>
                {button}
                {modal}
            </div>
        );
    },

    componentDidMount: function() {
    },

    componentDidUpdate: function(prevProps, prevState) {
        if (this.props.selection !== prevProps.selection) {
            this.setState({ selection: this.props.selection });
        }
    }
});
