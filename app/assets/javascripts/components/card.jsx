const Card = ({ children, title }) => (
    <div className='card'>
        <div className='card-content'>
            <div className='card-header'>
                <h3>{title}</h3>
            </div>
            <div className='row'>
                <div className='col l12'>
                    {children}
                </div>
            </div>
        </div>
    </div>
);

Card.PropTypes = {
    title: React.PropTypes.string,
    children: React.PropTypes.any,
};
