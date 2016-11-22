class CollapsibleWrapper extends React.Component {
    static propTypes = {
        children: React.PropTypes.any,
        className: React.PropTypes.string,
        id: React.PropTypes.string,
    }

    componentDidMount() {
        $(this.collapsible).collapsible({
            accordion: false,
        });
    }

    render() {
        const { className, id, children } = this.props;
        return (
            <ul
                id={id}
                data-collapsible='expandable'
                ref={collapsible => { this.collapsible = collapsible; }}
                className={`collapsible ${className ? className : ''}`}
            >
                {children}
            </ul>
        );
    }
};
