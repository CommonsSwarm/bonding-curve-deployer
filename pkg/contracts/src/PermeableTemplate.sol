pragma solidity 0.6.2;

import "./BaseTemplate.sol";

interface AugmentedBondingCurve {
    function initialize(
        TokenManager _tokenManager,
        address _formula,
        Vault _reserve,
        address _beneficiary,
        uint256 _buyFeePct,
        uint256 _sellFeePct
    ) external;
}

contract PermeableTemplate is BaseTemplate, TokenCache {
    string private constant ERROR_EMPTY_HOLDERS = "PERMEABLE_EMPTY_HOLDERS";
    string private constant ERROR_BAD_HOLDERS_STAKES_LEN = "PERMEABLE_BAD_HOLDERS_STAKES_LEN";
    string private constant ERROR_BAD_VOTE_SETTINGS = "PERMEABLE_BAD_VOTE_SETTINGS";

    bool private constant TOKEN_TRANSFERABLE = true;
    uint8 private constant TOKEN_DECIMALS = uint8(18);
    uint256 private constant TOKEN_MAX_PER_ACCOUNT = uint256(0);
    uint64 private constant DEFAULT_FINANCE_PERIOD = uint64(30 days);

    bytes32 internal constant ABC_APP_ID = 0x952fcbadf8d7288f1a8b47ed7ee931702318b527558093398674db0c93e3a75b;

    constructor(address _daoFactory, address _ens, address _miniMeFactory, address _aragonID)
        public
        BaseTemplate(
            DAOFactory(_daoFactory),
            ENS(_ens),
            MiniMeTokenFactory(_miniMeFactory),
            IFIFSResolvingRegistrar(_aragonID)
        )
    {
        _ensureAragonIdIsValid(address(_aragonID));
        _ensureMiniMeFactoryIsValid(address(_miniMeFactory));
    }

    /**
     * @dev Create a new MiniMe token and deploy a Permeable DAO. This function does not allow Payroll
     *      to be setup due to gas limits.
     * @param _tokenName String with the name for the token used by share holders in the organization
     * @param _tokenSymbol String with the symbol for the token used by share holders in the organization
     * @param _id String with the name for org, will assign `[id].aragonid.eth`
     * @param _holders Array of token holder addresses
     * @param _stakes Array of token stakes for holders (token has 18 decimals, multiply token amount `* 10^18`)
     * @param _votingSettings Array of [supportRequired, minAcceptanceQuorum, voteDuration] to set up the voting app of the organization
     * @param _useAgentAsVault Boolean to tell whether to use an Agent app as a more advanced form of Vault app
     * @param _buyFeePct Fee percentage when buying tokens from ABC
     * @param _sellFeePct Fee percentage when selling tokens from ABC
     */
    function newTokenAndInstance(
        string calldata _tokenName,
        string calldata _tokenSymbol,
        string calldata _id,
        address[] calldata _holders,
        uint256[] calldata _stakes,
        uint64[3] calldata _votingSettings,
        bool _useAgentAsVault,
        uint256 _buyFeePct,
        uint256 _sellFeePct
    ) external {
        newToken(_tokenName, _tokenSymbol);
        newInstance(_id, _holders, _stakes, _votingSettings, _useAgentAsVault, _buyFeePct, _sellFeePct);
    }

    /**
     * @dev Create a new MiniMe token and cache it for the user
     * @param _name String with the name for the token used by share holders in the organization
     * @param _symbol String with the symbol for the token used by share holders in the organization
     */
    function newToken(string memory _name, string memory _symbol) public returns (MiniMeToken) {
        MiniMeToken token = _createToken(_name, _symbol, TOKEN_DECIMALS);
        _cacheToken(token, msg.sender);
        return token;
    }

    /**
     * @dev Deploy a Permeable DAO using a previously cached MiniMe token
     * @param _id String with the name for org, will assign `[id].aragonid.eth`
     * @param _holders Array of token holder addresses
     * @param _stakes Array of token stakes for holders (token has 18 decimals, multiply token amount `* 10^18`)
     * @param _votingSettings Array of [supportRequired, minAcceptanceQuorum, voteDuration] to set up the voting app of the organization
     * @param _useAgentAsVault Boolean to tell whether to use an Agent app as a more advanced form of Vault app
     */
    function newInstance(
        string memory _id,
        address[] memory _holders,
        uint256[] memory _stakes,
        uint64[3] memory _votingSettings,
        bool _useAgentAsVault,
        uint256 _buyFeePct,
        uint256 _sellFeePct
    ) public {
        _validateId(_id);
        _ensureSettings(_holders, _stakes, _votingSettings);

        (Kernel dao, ACL acl) = _createDAO();
        (Finance finance, Voting voting) =
            _setupApps(dao, acl, _holders, _stakes, _votingSettings, _useAgentAsVault, _buyFeePct, _sellFeePct);
        _transferCreatePaymentManagerFromTemplate(acl, finance, address(voting));
        _transferRootPermissionsFromTemplateAndFinalizeDAO(dao, address(voting));
        _registerID(_id, address(dao));
    }

    function _setupApps(
        Kernel _dao,
        ACL _acl,
        address[] memory _holders,
        uint256[] memory _stakes,
        uint64[3] memory _votingSettings,
        bool _useAgentAsVault,
        uint256 _buyFeePct,
        uint256 _sellFeePct
    ) internal returns (Finance, Voting) {
        MiniMeToken token = _popTokenCache(msg.sender);
        Vault agentOrVault = _useAgentAsVault ? Vault(address(_installDefaultAgentApp(_dao))) : _installVaultApp(_dao);
        Finance finance = _installFinanceApp(_dao, agentOrVault, DEFAULT_FINANCE_PERIOD);
        TokenManager tokenManager = _installTokenManagerApp(_dao, token, TOKEN_TRANSFERABLE, TOKEN_MAX_PER_ACCOUNT);
        Voting voting = _installVotingApp(_dao, token, _votingSettings);

        _mintTokens(_acl, tokenManager, _holders, _stakes);
        _setupPermissions(_acl, agentOrVault, voting, finance, tokenManager, _useAgentAsVault);

        _setupPermeableApps(_dao, _acl, tokenManager, address(agentOrVault), _buyFeePct, _sellFeePct, address(voting));
        _transferTokenManagerFromTemplate(_acl, tokenManager, address(voting));

        return (finance, voting);
    }

    function _setupPermissions(
        ACL _acl,
        Vault _agentOrVault,
        Voting _voting,
        Finance _finance,
        TokenManager _tokenManager,
        bool _useAgentAsVault
    ) internal {
        if (_useAgentAsVault) {
            _createAgentPermissions(_acl, Agent(address(_agentOrVault)), address(_voting), address(_voting));
        }
        _createVaultPermissions(_acl, _agentOrVault, address(_finance), address(_voting));
        _createFinancePermissions(_acl, _finance, address(_voting), address(_voting));
        _createFinanceCreatePaymentsPermission(_acl, _finance, address(_voting), address(this));
        _createEvmScriptsRegistryPermissions(_acl, address(_voting), address(_voting));
        _createVotingPermissions(_acl, _voting, address(_voting), address(_tokenManager), address(_voting));
        _createTokenManagerPermissions(_acl, _tokenManager, address(_voting), address(this));
    }

    function _setupPermeableApps(
        Kernel _dao,
        ACL _acl,
        TokenManager _tokenManager,
        address _beneficiary,
        uint256 _buyFeePct,
        uint256 _sellFeePct,
        address _vaultManager
    ) internal {
        // install new permeable vault
        Vault _permeableVault = _installVaultApp(_dao);

        address _formula = 0xA4e28453b4F3fcB251EEbe1aC2798eEE55e2bE6a;

        AugmentedBondingCurve _augmentedBondingCurve = _installAugmentedBondingCurve(
            _dao, _tokenManager, _formula, _permeableVault, _beneficiary, _buyFeePct, _sellFeePct
        );

        // last thing to do
        _setupPermeablePermissions(_acl, _tokenManager, _permeableVault, _augmentedBondingCurve, _vaultManager);
    }

    function _setupPermeablePermissions(
        ACL _acl,
        TokenManager _tokenManager,
        Vault _permeableVault,
        AugmentedBondingCurve _augmentedBondingCurve,
        address _vaultManager
    ) internal {
        _createVaultPermissions(_acl, _permeableVault, address(_augmentedBondingCurve), _vaultManager);
        _grantTokenManagerPermissions(_acl, _tokenManager, address(_augmentedBondingCurve));
    }

    function _transferTokenManagerFromTemplate(ACL _acl, TokenManager _tokenManager, address _manager) internal {
        _acl.setPermissionManager(_manager, address(_tokenManager), _tokenManager.BURN_ROLE());
        _acl.setPermissionManager(_manager, address(_tokenManager), _tokenManager.MINT_ROLE());
    }

    function _grantTokenManagerPermissions(ACL _acl, TokenManager _tokenManager, address _to) internal {
        _acl.grantPermission(_to, address(_tokenManager), _tokenManager.BURN_ROLE());
        _acl.grantPermission(_to, address(_tokenManager), _tokenManager.MINT_ROLE());
    }

    function _installAugmentedBondingCurve(
        Kernel _dao,
        TokenManager _tokenManager,
        address _formula,
        Vault _reserve,
        address _beneficiary,
        uint256 _buyFeePct,
        uint256 _sellFeePct
    ) internal returns (AugmentedBondingCurve) {
        bytes memory initializeData = abi.encodeWithSelector(
            AugmentedBondingCurve(0).initialize.selector,
            _tokenManager,
            _formula,
            _reserve,
            _beneficiary,
            _buyFeePct,
            _sellFeePct
        );
        return AugmentedBondingCurve(_installNonDefaultApp(_dao, ABC_APP_ID, initializeData));
    }

    function _ensureSettings(address[] memory _holders, uint256[] memory _stakes, uint64[3] memory _votingSettings)
        private
        pure
    {
        require(_holders.length > 0, ERROR_EMPTY_HOLDERS);
        require(_holders.length == _stakes.length, ERROR_BAD_HOLDERS_STAKES_LEN);
        require(_votingSettings.length == 3, ERROR_BAD_VOTE_SETTINGS);
    }
}
