function volatility = Kit_blsimpv(S, X, r, T, value, optionClass)
% Record array dimensions for output argument formatting.
[nRows, nCols] = size(S);
volatility = zeros(nRows * nCols, 1);

% default
q = volatility;
tol = 1e-6;
optionClass = logical(optionClass);
r(1 : nRows, 1) = r;
limit = 10;

% Now estimate the implied volatility for each option.
options = optimset('fzero');
options = optimset(options, 'TolX', tol, 'Display', 'off');

for i = 1:length(volatility)
    if (S(i) > 0) && (X(i) > 0) && (T(i) > 0)
        try
            [volatility(i), ~, ~] = fzero(@objfcn, [0 limit], options, ...
                S(i), X(i), r(i), T(i), value(i), q(i), optionClass(i));
        catch
        end
    end
end

% Reshape the outputs for the user.
volatility = reshape(volatility, nRows, nCols);

% * * * * * * * Implied Volatility Objective Function * * * * * * *

function delta = objfcn(volatility, S, X, r, T, value, q, optionClass)
%OBJFCN Implied volatility objective function.
% The objective function is simply the difference between the specified
% market value, or price, of the option and the theoretical value derived
% from the Black-Scholes model.
%

[callValue, putValue] = Kit_blsprice(S, X, r, T, volatility, q);

if optionClass
    delta = value - callValue;
else
    delta = value - putValue;
end


function [call,put] = Kit_blsprice(S, X, r, T, sig, q)

% Double up on fcn calls since blsprice calculates both calls and puts. Do
% this only if nargout>1
NumOpt = numel(S);
callSpec = {'call'};
callSpec = callSpec(ones(NumOpt,1));
putSpec = {'put'};
putSpec = putSpec(ones(NumOpt,1));

OptSpec = [callSpec;putSpec];

% blspriceeng works with columns. Get sizes, turn to columns, run engine,
% and finally turn to arrays again:
[m, n] = size(S);

% Double up the rest of the input args
    [S, X, r, T, sig, q] = deal([S(:);S(:)], [X(:);X(:)], [r(:);r(:)], ...
        [T(:);T(:)], [sig(:);sig(:)], [q(:);q(:)]);

% Call eng function
price = Kit_blspriceeng(OptSpec(:), S(:), X(:), r(:), T(:), sig(:), q(:));

% Now separate calls from puts
call = price(1:NumOpt);
call = reshape(call, m, n);
put = price(NumOpt+1:end);
put  = reshape(put, m, n);

function price = Kit_blspriceeng(OptSpec, S, X, r, OptMatTime, sig, q)
% BLSPRICEENG Engine function for Black-Scholes option pricing model.
%
%   This is a private function that is not meant to be called directly
%   by the user.

%   Copyright 1998-2016 The MathWorks, Inc. 


% --------------------------------------------------
% FwdExpiryTime defaults to OptMatTime when not specified.
% --------------------------------------------------
FwdExpiryTime = OptMatTime;
OptSpec = string(OptSpec);

% Create convenience mask
callMask = strcmpi(OptSpec, 'call');
putMask = ~callMask;

% vector initialization:
price = zeros(size(S));

% Enforce some boundary conditions that produce warnings (e.g.,
% logarithm of zero and divide by zero) and potential NaN's in
% the output option price arrays:
%
%  (1) At expiration (i.e., OptMatTime = 0), the price of all options is
%      simply the greater of their intrinsic value and zero.
%
%  (2) When the price of the underlying asset is zero (i.e.,
%      S = 0), the value of a call option is zero and the
%      value of a put option is equal to its present value of
%      the strike price (X). This boundary condition enforces
%      the "absorbing barrier" property associated with the
%      geometric Brownian motion diffusion process governing
%      the price path of the underlying asset (S).
%
%  (3) When the strike price is zero (i.e., X = 0), the
%      value of a put option is zero and the value of a call
%      option is equal to the price of the underlyer (S).

isTimeZero = (OptMatTime == 0);         % Expired options.
isStockZero = (S == 0);
isStrikeZero = (X == 0);

% Now apply the general Black-Scholes European option pricing
% formula, excluding the boundary cases handled above, and
% explicitly handling calculations that produce 0/0 = NaN's
% for the parameters of the cumulative normal distribution
% function (i.e., d1 & d2).
%
% NaN's occur when S = X, r = q, and Sigma = 0. This situation
% corresponds to at-the-money options written on riskless
% underlying assets. Such assets should earn the risk-free rate
% less the dividend yield. But when r = q, the net growth rate
% is also zero, resulting in 0/0 = NaN.
%

i = ~(isTimeZero | isStockZero | isStrikeZero);

d1 = zeros(size(S));
d1(i) = log(S(i)./X(i)) + (r(i) - q(i) + sig(i).^2/2) .* OptMatTime(i);
d1(i) = d1(i) ./(sig(i).*sqrt(OptMatTime(i)));
d1(isnan(d1)) = 0;

d2 = zeros(size(S));
d2(i) = d1(i) - (sig(i).*sqrt(OptMatTime(i)));
d2(isnan(d2)) = 0;

% Populate price vector
callFactor = 2*callMask-1;
price(isTimeZero) = max(callFactor(isTimeZero) .* (S(isTimeZero) - X(isTimeZero)), 0);

price(isStockZero & callMask)  = 0;                % Worthless calls.
pzmask = isStockZero & putMask;
if any(pzmask)
    price(pzmask) = X(pzmask) .* exp(-r(pzmask).*OptMatTime(pzmask));
else
end

czmask = callMask & isStrikeZero;
price(czmask) = S(czmask).* exp(-q(czmask) .* OptMatTime(czmask));
price(putMask & (X == 0)) = 0;                % Worthless puts.

% calculate option prices for the rest of the options:
callCalcMask = callMask & i;
price(callCalcMask) = S(callCalcMask) .* exp(-q(callCalcMask).*FwdExpiryTime(callCalcMask)) .* normcdf( d1(callCalcMask)) - ...
    X(callCalcMask) .* exp(-r(callCalcMask).*FwdExpiryTime(callCalcMask)) .* normcdf( d2(callCalcMask));

putCalcMask  = putMask & i;
price(putCalcMask) = X(putCalcMask) .* exp(-r(putCalcMask).*FwdExpiryTime(putCalcMask)) .* normcdf(-d2(putCalcMask)) - ...
    S(putCalcMask) .* exp(-q(putCalcMask).*FwdExpiryTime(putCalcMask)) .* normcdf(-d1(putCalcMask));



