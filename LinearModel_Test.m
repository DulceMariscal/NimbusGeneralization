classdef (Sealed = true, InferiorClasses = {?matlab.graphics.axis.Axes, ?matlab.ui.control.UIAxes}) LinearModel < classreg.regr.CompactLinearModel & classreg.regr.TermsRegression
    %LinearModel Fitted multiple linear regression model.
    %   LM = FITLM(...) fits a linear model to data. The fitted model LM is a
    %   LinearModel that can predict a response as a linear function of
    %   predictor variables and terms created from predictor variables.
    %
    %   LinearModel methods:
    %       addTerms - Add terms to linear model
    %       removeTerms - Remove terms from linear model
    %       step - Selectively add or remove terms from linear model
    %       anova - Analysis of variance
    %       coefCI - Coefficient confidence intervals
    %       coefTest - Linear hypothesis test on coefficients
    %       predict - Compute predicted values given predictor values
    %       feval - Evaluate model as a function
    %       random - Generate random response values given predictor values
    %       dwtest - Durbin-Watson test for autocorrelation in residuals
    %       plot - Summary plot of regression model
    %       plotAdded - Plot of marginal effect of a single term
    %       plotAdjustedResponse - Plot of response and one predictor
    %       plotDiagnostics - Plot of regression diagnostics
    %       plotEffects - Plot of main effects of predictors
    %       plotInteraction - Plot of interaction effects of two predictors
    %       plotPartialDependence - Partial dependence plot for 1-D or 2-D visualization
    %       plotResiduals - Plot of residuals
    %       plotSlice - Plot of slices through fitted regression surface
    %       compact - Create compact version of LinearModel
    %
    %   LinearModel properties:
    %       Coefficients - Coefficients and related statistics
    %       Rsquared - R-squared and adjusted R-squared
    %       ModelCriterion - AIC and other model criteria
    %       Fitted - Vector of fitted (predicted) values
    %       Residuals - Table containing residuals of various types
    %       ResponseName - Name of response
    %       PredictorNames - Names of predictors
    %       NumPredictors - Number of predictors
    %       Variables - Table of variables used in fit
    %       NumVariables - Number of variables used in fit
    %       VariableNames - Names of variables used in fit
    %       VariableInfo - Information about variables used in the fit
    %       NumObservations - Number of observations in the fit
    %       ObservationNames - Names of observations in the fit
    %       ObservationInfo - Information about observations used in the fit
    %       Diagnostics - Regression diagnostics
    %       MSE - Mean squared error (estimate of residual variance)
    %       RMSE - Root mean squared error (estimate of residual standard deviation)
    %       DFE - Degrees of freedom for residuals
    %       SSE - Error sum of squares
    %       SST - Total sum of squares
    %       SSR - Regression sum of squares
    %       Steps - Stepwise fit results
    %       Robust - Robust fit results
    %       Formula - Representation of the model used in this fit
    %       LogLikelihood - Log of likelihood function at coefficient estimates
    %       CoefficientCovariance - Covariance matrix for coefficient estimates
    %       CoefficientNames - Coefficient names
    %       NumCoefficients - Number of coefficients
    %       NumEstimatedCoefficients - Number of estimated coefficients
    %
    %   See also FITLM, GeneralizedLinearModel, NonLinearModel, STEPWISELM.
    
    %   Copyright 2011-2019 The MathWorks, Inc.
    
    properties(Constant,Hidden)
        SupportedResidualTypes = {'Raw' 'Pearson' 'Standardized' 'Studentized'};
    end

    properties(GetAccess='protected',SetAccess='protected')
        Q
    end
    properties(Dependent=true,GetAccess='public',SetAccess='protected')
        %Residuals - Residual values.
        %   The Residuals property is a table of residuals. It is a table array that
        %   has one row for each observation and the following variables:
        %
        %        'Raw'          Observed minus fitted values
        %        'Pearson'      Raw residuals divided by RMSE
        %        'Standardized' Raw residuals divided by their estimated standard
        %                       deviation
        %        'Studentized'  Raw residuals divided by an independent (delete-1)
        %                       estimate of their standard deviation
        %
        %   To obtain any of these columns as a vector, index into the property
        %   using dot notation. For example, in the model M, the ordinary or
        %   raw residual vector is
        %
        %      r = M.Residuals.Raw
        %
        %   See also LinearModel, plotResiduals, Fitted, predict, random.
        Residuals
        
        %Fitted - Fitted (predicted) values.
        %   The Fitted property is a vector of fitted values.
        %
        %   The fitted values are computed using the predictor values used to fit
        %   the model. Use the PREDICT method to compute predictions for other
        %   predictor values and to compute confidence bounds for the predicted
        %   values.
        %
        %   See also LinearModel, Residuals, predict, random.
        Fitted
        
        %Diagnostics - Regression diagnostics.
        %   The Diagnostics property is a structure containing a set of diagnostics
        %   helpful in finding outliers and influential observations. Many describe
        %   the effect on the fit of deleting single observations.  The structure
        %   contains the following fields:
        %      Leverage  Diagonal elements of the Hat matrix
        %      Dffits    Scaled change in fitted values with row deletion
        %      CooksDistance Cook's measure of scaled change in fitted values
        %      S2_i      Residual variance estimate with row deletion
        %      Dfbetas   Scaled change in coefficient estimates with row deletion
        %      CovRatio  Covariance determinant ratio with row deletion
        %      HatMatrix Projection matrix to compute fitted from observed responses
        %
        %   Leverage indicates to what extent the predicted value for an
        %   observation is determined by the observed value for that observation. A
        %   value close to 1 indicates that the prediction is largely determined by
        %   that observation, with little contribution from the other observations.
        %   A value close to 0 indicates the fit is largely determined by the other
        %   observations. For a model with P coefficients and N observations, the
        %   average value of Leverage is P/N. Observations with Leverage larger
        %   than 2*P/N may be considered to have high leverage.
        %
        %   Dffits is the scaled change in the fitted values for each observation
        %   that would result from excluding that observation from the fit. Values
        %   with an absolute value larger than 2*sqrt(P/N) may be considered
        %   influential.
        %
        %   CooksDistance is another measure of scaled change in fitted values. A
        %   value larger than three times the mean Cook's distance may be
        %   considered influential.
        %
        %   S2_i is a set of residual variance estimates obtained by deleting each
        %   observation in turn. These can be compared with the value of the MSE
        %   property.
        %
        %   Dfbetas is an N-by-P matrix of the scaled change in the coefficient
        %   estimates that would result from excluding each observation in turn.
        %   Values larger than 3/sqrt(N) in absolute value indicate that the
        %   observation has a large influence on the corresponding coefficient.
        %
        %   CovRatio is the ratio of the determinant of the coefficient covariance
        %   matrix with each observation deleted in turn to the determinant of the
        %   covariance matrix for the full model. Values larger than 1+3*P/N or
        %   smaller than 1-3*P/N indicate influential points.
        %
        %   HatMatrix is an N-by-N matrix H such that Yfit=H*Y where Y is the
        %   response vector and Yfit is the vector of fitted response values.
        %
        %   See also LinearModel, GeneralizedLinearModel, NonLinearModel.
        Diagnostics
    end
    
    methods % get/set methods
        function yfit = get.Fitted(model)
            yfit = get_fitted(model);
        end
        function r = get.Residuals(model)
            r = get_residuals(model);
        end
        
        % The following code is removed because it causes a bad interaction with
        % the array editor. As a result, the Diagnostics propety does not appear in
        % the array editor view of the LinearModel object. Diagnostics property
        % access from the command line is provided in the subsref method.
        
        function D = get.Diagnostics(model)
            D = get_diagnostics(model);
        end
    end
    methods(Access='protected')
        function s2_i = get_S2_i(model)
            r = getResponse(model) - predict(model);
            h = model.Leverage; % from parent class
            wt = get_CombinedWeights_r(model,false);
            delta_i = wt .* abs(r).^2 ./ (1-h);
            if any(h==1)
                % If any points are completely determined by their own
                % observation, then removing those points doesn't decrease
                % the SSE and also doesn't decrease the DFE
                newdf = repmat(model.DFE-1,length(h),1);
                delta_i(h==1) = 0;
                newdf(h==1) = newdf(h==1) + 1;
            else
                newdf = model.DFE-1;
            end
            s2_i = max(0,model.SSE - delta_i) ./ newdf;
            subset = model.ObservationInfo.Subset;
            s2_i(~subset & ~isnan(s2_i)) = 0;
        end
        function dfbetas = get_Dfbetas(model)
            rows = model.ObservationInfo.Subset;
            w_r = get_CombinedWeights_r(model);
            [~,~,~,R1,~,~,~,Q1] = lsfit(model.design_r,model.y_r,w_r);
            C = Q1/R1';
            e_i = model.Residuals.Studentized(rows,:);
            h = model.Leverage(rows,:); % from parent class
            dfbetas = zeros(length(e_i),size(C,2));
            dfb = bsxfun(@rdivide,C,sqrt(sum(C.^2)));
            dfb = bsxfun(@times,dfb, sqrt(w_r).*e_i./sqrt(1-h));
            dfbetas(rows,:) = dfb;
        end
        function dffits = get_Dffits(model)
            e_i = model.Residuals.Studentized;
            wt = get_CombinedWeights_r(model,false);
            h = model.Leverage; % from parent class
            dffits = sqrt(h./(1-h)).*sqrt(wt).*e_i;
        end
        function covr = get_CovRatio(model)
            n = model.NumObservations;
            p = model.NumEstimatedCoefficients;
            wt = get_CombinedWeights_r(model,false);
            e_i = model.Residuals.Studentized;
            h = model.Leverage; % from parent class
            covr = 1 ./ ((((n-p-1+wt.*abs(e_i).^2)./(n-p)).^p).*(1-h));
        end
        function w = get_CombinedWeights_r(model,reduce)
            w = model.ObservationInfo.Weights;
            if ~isempty(model.Robust)
                w = w .* model.Robust.Weights;
            end
            if nargin<2 || reduce
                subset = model.ObservationInfo.Subset;
                w = w(subset);
            end
        end
    end % get/set methods

    methods(Hidden=true, Access='public') % public to allow testing
        [fxi,fxiVar] = getAdjustedResponse(model,var,xi,terminfo)
%         [effects,effectSEs,effectnames,effectXs] = getEffects(model,vars,terminfo)
%         [effect,effectSE,effectName] = getConditionalEffect(model,var1,var2,xi1,terminfo)
    end

    methods(Hidden=true, Access='public')
        function model = LinearModel(varargin) % modelDef, coefs, ...
            if nargin == 0 % special case
                model.Formula = classreg.regr.LinearFormula;
                return
            end
            error(message('stats:LinearModel:NoConstructor'));
        end
        
        % Implementation of VariableEditorPropertyProvider to customize
        % the display of properties in the Variable Editor
        function isVirtual = isVariableEditorVirtualProp(~,prop)
            % Return true for the Diagnostics property to enable the
            % Variable Editor to derive the Diagnostics property display
            % without actually accessing the Diagnostics property
            % (which may cause memory overflows).
            isVirtual = strcmp(prop,'Diagnostics');
        end
        function isComplex = isVariableEditorComplexProp(~,~)
            % Diagnostics property should not be complex
            isComplex = false;
        end
        function isSparse = isVariableEditorSparseProp(~,~)
            % Diagnostics property should not be sparse
            isSparse = false;
        end
        function className = getVariableEditorClassProp(~,~)
            % Diagnostics property in the Variable Editor is table object
            className = 'table';
        end
        function sizeArray = getVariableEditorSize(this,~)
            sizeArray = [size(this.ObservationInfo.Subset,1); 7];
        end
    end
    
    methods(Access='public')
        % The implementation is in dwtest.m file.
        [p,stat] = dwtest(model,option,tail)
        
        function disp(model)
            %DISP Display a LinearModel.
            %   DISP(LM) displays the LinearModel LM.
            %
            %   See also LinearModel.
            isLoose = strcmp(get(0,'FormatSpacing'),'loose');
            if (isLoose), fprintf('\n'); end
            if isempty(model.Robust)  % non-robust
                fprintf('%s',getString(message('stats:LinearModel:display_LinearRegressionModel')));
            else                      % robust
                fprintf('%s',getString(message('stats:LinearModel:display_LinearRegressionModelrobustFit')));
            end
            
            dispBody(model)
        end
        % --------------------------------------------------------------------
        function [varargout] = predict(model,varargin)
            %predict Compute predicted values given predictor values.
            %   YPRED = PREDICT(LM,DS) computes a vector YPRED of predicted values from
            %   the LinearModel LM using predictor variables from the dataset/table DS. DS
            %   must contain all of the predictor variables used to create LM.
            %
            %   YPRED = PREDICT(LM,X), where X is a data matrix with the same number of
            %   columns as the matrix used to create LM, computes predictions using the
            %   values in X.
            %
            %   [YPRED,YCI] = PREDICT(...) also returns the two-column matrix YCI
            %   containing 95% confidence intervals for the predicted values. These are
            %   non-simultaneous intervals for predicting the mean response at the
            %   specified predictor values. The lower limits of the bounds are in
            %   column 1, and the upper limits are in column 2.
            %
            %   [...] = PREDICT(LM,DS,PARAM1,VAL1,PARAM2,VAL2,...) or
            %   [...] = PREDICT(LM,X,PARAM1,VAL1,PARAM2,VAL2,...) specifies one or more
            %   of the following name/value pairs:
            %
            %      'Alpha'        A value between 0 and 1 to specify the confidence
            %                     level as 100(1-ALPHA)%.  Default is 0.05 for 95%
            %                     confidence.
            %      'Simultaneous' Either true for simultaneous bounds, or false (the
            %                     default) for non-simultaneous bounds.
            %      'Prediction'   Either 'curve' (the default) to compute confidence
            %                     intervals for the curve (function value) at X, or
            %                     'observation' for prediction intervals for a new
            %                     observation at X.
            %
            %   Example:
            %      % Create a regression model and use it to compute predictions
            %      % and confidence intervals for the value of the function for
            %      % the first three observations
            %      load carsmall
            %      d = dataset(MPG,Weight);
            %      d.Year = ordinal(Model_Year);
            %      lm = fitlm(d,'MPG ~ Year + Weight + Weight^2')
            %      [fitted,confint] = predict(lm,d(1:3,:))
            %
            %   See also LinearModel, random.
            [varargin{:}] = convertStringsToChars(varargin{:});
            if nargin > 1 && ~internal.stats.isString(varargin{1})
                Xpred = varargin{1};
                varargin = varargin(2:end);
                if isa(Xpred,'tall')
                    [varargout{1:max(1,nargout)}] = hSlicefun(@model.predict,Xpred,varargin{:});
                    return
                end
                design = designMatrix(model,Xpred);
            else
                design = model.Design;
            end
            [varargout{1:max(1,nargout)}] = predictDesign(model,design,varargin{:});
        end
        
        % --------------------------------------------------------------------
        function model = step(model,varargin)
            %STEP Selectively add or remove terms from a regression model.
            %   M2 = STEP(M1) refines the regression model M1 by taking one step of a
            %   stepwise regression, and returns the new model as M2. STEP first tries
            %   to add a new term with a p-value less than 0.05. If none is found, it
            %   tries to remove a term with a p-value greater than 0.10. If none is
            %   found, it returns M2 with the same terms as in M1.
            %
            %   The STEP method is not available with robust fits.
            %
            %   M2 = STEP(M1,'PARAM1',val1,'PARAM2',val2,...) specifies one or more of
            %   the following name/value pairs:
            %
            %      'Lower'     Lower model of terms that must remain in the model,
            %                  default='constant'
            %      'Upper'     Upper model of terms available to be added to the model,
            %                  default='interactions'
            %      'Criterion' Criterion to use in evaluating terms to add or remove,
            %                  chosen from 'SSE' (default) 'AIC', 'BIC', 'RSquared',
            %                  'AdjRsquared'
            %      'PEnter'    For the 'SSE' criterion, a value E such that a term may
            %                  be added if its p-value is less than or equal to E. For
            %                  the other criteria, a term may be added if the
            %                  improvement in the criterion is at least E.
            %      'PRemove'   For the 'SSE' criterion, a value R such that a term may
            %                  be removed if its p-value is greater or equal to R. For
            %                  the other criteria, a term may be added if it reduces
            %                  the criterion no more than R.
            %      'NSteps'    Maximum number of steps to take, default=1
            %      'Verbose'   An integer from 0 to 2 controlling the display of
            %                  information. Verbose=1 (the default) displays the action
            %                  taken at each step. Verbose=2 also displays the actions
            %                  evaluated at each step. Verbose=0 suppresses all
            %                  display.
            %
            %   The following table shows the default 'PEnter' and 'PRemove' values for
            %   the different criteria, and indicates which must be larger than the
            %   other:
            %
            %      Criterion     PEnter   PRemove    Compared against
            %      'SSE'         0.05   < 0.10       p-value for F test
            %      'AIC'         0      < 0.01       change in AIC
            %      'BIC'         0      < 0.01       change in BIC
            %      'Rsquared'    0.1    > 0.05       increase in R-squared
            %      'AdjRsquared' 0      > -0.05      increase in adjusted R-squared
            %
            %    Example:
            %       % Fit model to car data; check for any term to add or remove from a
            %       % quadratic model
            %       load carsmall
            %       d = dataset(MPG,Weight);
            %       d.Year = ordinal(Model_Year);
            %       lm1 = fitlm(d,'MPG ~ Year + Weight + Weight^2')
            %       lm2 = step(lm1,'upper','quadratic')
            %
            %   See also LinearModel, FITLM, STEPWISELM.
            compactNotAllowed(model,'step',false);
            [varargin{:}] = convertStringsToChars(varargin{:});
            if ~isempty(model.Robust)
                error(message('stats:LinearModel:NoRobustStepwise'));
            end
            model = step@classreg.regr.TermsRegression(model,varargin{:});
            checkDesignRank(model);
        end
        
        function lm = compact(this)
        %COMPACT Compact linear regression model.
        %    CLM=COMPACT(LM) takes a linear model LM and returns CLM as a compact
        %    version of it. The compact version is smaller and has fewer methods.
        %    It omits properties such as Residuals and Diagnostics that are of the
        %    same size as the data used to fit the model. It lacks methods such as
        %    step and plotResiduals that require such properties.
        %
        %    See also fitlm, LinearModel, classreg.regr.CompactLinearModel.
            
            % Compute means of terms that are sub-terms of terms that are
            % actually in the model. For a full object these are computed
            % as needed, so before compacting make sure they are all
            % available.
            if isempty(this.TermMeans)
                lm = getTermMeans(this);
            else
                lm = this;
            end
            
            lm = classreg.regr.CompactLinearModel.make(lm);
        end
        
        
  
    end
    methods(Access='public')  % plotting methods
        % The implementations of these functions are in their corresponding
        % .m files.
        hout = plot(varargin)
        hout = plotAdded(varargin)
        hout = plotAdjustedResponse(model,var,varargin)
        
        
        % -------------------- pass throughs to modelutils -------------------
        function hout = plotDiagnostics(model,varargin)
            %plotDiagnostics Plot diagnostics of fitted model
            %    plotDiagnostics(LM,PLOTTYPE) plots diagnostics from LinearModel LM in
            %    a plot of type PLOTTYPE. The default value of PLOTTYPE is 'leverage'.
            %    Valid values for PLOTTYPE are:
            %
            %       'contour'      residual vs. leverage with overlayed Cook's contours
            %       'cookd'        Cook's distance
            %       'covratio'     delete-1 ratio of determinant of covariance
            %       'dfbetas'      scaled delete-1 coefficient estimates
            %       'dffits'       scaled delete-1 fitted values
            %       'leverage'     leverage (diagonal of Hat matrix)
            %       's2_i'         delete-1 variance estimate
            %
            %    H = plotDiagnostics(...) returns handles to the lines in the plot.
            %
            %    The PLOTTYPE argument can be followed by parameter/value pairs to
            %    specify additional properties of the primary line in the plot. For
            %    example, plotDiagnostics(LM,'cookd','Marker','s') uses a square
            %    marker.
            %
            %    The data cursor tool in the figure window will display the X and Y
            %    values for any data point, along with the observation name or number.
            %    It also displays the coefficient name for 'dfbetas'.
            %
            %    Example:
            %      % Plot the leverage in a fitted regression model
            %      load carsmall
            %      d = dataset(MPG,Weight);
            %      d.Year = ordinal(Model_Year);
            %      lm = fitlm(d,'MPG ~ Year + Weight + Weight^2')
            %      plotDiagnostics(lm,'leverage')
            %
            %      % Look at the data for the high-leverage points, and note that
            %      % their Weight values are near the extremes
            %      high = find(lm.Diagnostics.Leverage>0.11)
            %      d(high,:)
            %
            %    See also LinearModel, plotResiduals.
            
            compactNotAllowed(model,'plotDiagnostics',false);
            [varargin{:}] = convertStringsToChars(varargin{:});
            f = classreg.regr.modelutils.plotDiagnostics(model,varargin{:});
            if nargout>0
                hout = f;
            end
        end
        
        function hout = plotResiduals(varargin)
            %plotResiduals Plot residuals of fitted model
            %    plotResiduals(MODEL,PLOTTYPE) plots the residuals from model MODEL in
            %    a plot of type PLOTTYPE. Valid values for PLOTTYPE are:
            %
            %       'caseorder'     residuals vs. case (row) order
            %       'fitted'        residuals vs. fitted values
            %       'histogram'     histogram (default)
            %       'lagged'        residual vs. lagged residual (r(t) vs. r(t-1))
            %       'probability'   normal probability plot
            %       'symmetry'      symmetry plot
            %
            %    plotResiduals(MODEL,PLOTTYPE,'ResidualType',RTYPE) plots the residuals
            %    of type RTYPE, which can be any of the following:
            %
            %        'Raw'          Observed minus fitted values
            %        'Pearson'      Raw residuals divided by RMSE
            %        'Standardized' Raw residuals divided by their estimated standard
            %                       deviation
            %        'Studentized'  Raw residuals divided by an independent (delete-1)
            %                       estimate of their standard deviation
            %
            %    H = plotResiduals(...) returns a handle to the lines or patches in the
            %    plot.
            %
            %    plotResiduals(AX,...) plots into the axes with handle AX.
            %
            %    The PLOTTYPE or RTYPE arguments can be followed by parameter/value
            %    pairs to specify additional properties of the primary line in the
            %    plot. For example, plotResiduals(M,'fitted','Marker','s') uses a
            %    square marker.
            %
            %    For many of these plots, the data cursor tool in the figure window
            %    will display the X and Y values for any data point, along with the
            %    observation name or number.
            %
            %    Example:
            %      % Make a normal probability plot of the raw residuals in a fitted
            %      % regression model
            %      load carsmall
            %      d = dataset(MPG,Weight);
            %      d.Year = ordinal(Model_Year);
            %      lm = fitlm(d,'MPG ~ Year + Weight + Weight^2')
            %      plotResiduals(lm,'probability')
            %
            %      % Examine the points with the largest residuals
            %      high = find(lm.Residuals.Raw > 8)
            %      d(high,:)
            %
            %    See also LinearModel, plotDiagnostics.
            
            
            [ax, varargin, nargin] = axescheck(varargin{:});
            
            model = varargin{1};
            varargin = varargin(2:end);
            
            % Check if axes is a second argument. Note that if the function is called like
            % lm.plotResiduals(ax), the first argument will be 'lm' and second will be 'ax'.
            if isempty(ax)
                [ax, varargin] = axescheck(varargin{:});
                if ~isempty(ax)
                    nargin = nargin - 1;
                end
            end
            
            % If axes is found then add it as Name-Value pair.
            if ~isempty(ax)
                varargin = [varargin, 'Parent', {ax}];
            end
            
            if nargin > 1
                plottype = varargin{1};
                varargin = varargin(2:end);
                plottype = convertStringsToChars(plottype);
            end

            
            
            compactNotAllowed(model,'plotResiduals',false);
            if nargin<2
                plottype = 'histogram';
            end
            plottype = convertStringsToChars(plottype);
            [varargin{:}] = convertStringsToChars(varargin{:});
            [residtype,~,args] = internal.stats.parseArgs({'residualtype'},{'Raw'},varargin{:});
            varargin = args;
            residtype = internal.stats.getParamVal(residtype,...
                LinearModel.SupportedResidualTypes,'''ResidualType''');
            internal.stats.plotargchk(varargin{:});
            
            f = classreg.regr.modelutils.plotResiduals(model,plottype,'ResidualType',residtype,varargin{:});
            if nargout>0
                hout = f;
            end
        end
        
        
        
    end
    methods (Access='protected')
        function L0 = logLikelihoodNull(model)
            mu0 = sum(model.w_r .* model.y_r) / sum(model.w_r);
            sigma0 = std(model.y_r,model.w_r);
            L0 = sum(model.w_r .* normlogpdf(model.y_r,mu0,sigma0));
        end
        
        function h=plotxy(varargin)
            
            [ax, varargin] = axescheck(varargin{:});
            
            % If axes is found then add it as Name-Value pair.
            if ~isempty(ax)
                varargin = [varargin, 'Parent', {ax}];
            end
            
            lm = varargin{1};
            varargin = varargin(2:end);
                
            % Only one predictor, where is it?
            col = lm.PredLocs;
            xname = lm.PredictorNames{1};
            
            % Get its values
            xdata = getVar(lm,col);
            y = getResponse(lm);
            ObsNames = lm.ObservationNames;
            
            iscat = lm.VariableInfo.IsCategorical(col);
            
            if iscat
                % Compute fitted values for each level of this predictor
                [x,xlabels,levels] = grp2idx(xdata);
                tickloc = (1:length(xlabels))';
                ticklab = xlabels;
                xx = tickloc;
            else
                x = xdata;
                xx = linspace(min(x), max(x))';
                levels = xx;
            end
            nlevels = size(levels,1);
            
            % Make sure NaNs match up to avoid having unused values (those paired with
            % NaN in the other variable) affect the plot.
            t = isnan(x) | isnan(y);
            if any(t)
                x(t) = NaN;
                y(t) = NaN;
            end
            
            % Predict and plot
            if isa(lm.Variables,'dataset') || isa(lm.Variables,'table')
                % Create table to hold this variable
                X = lm.Variables(ones(nlevels,1),:);
                X.(xname) = levels(:);       % for prediction
            else
                % Create matrix to hold this variable
                npreds = lm.NumVariables-1;
                X = zeros(length(xx),npreds);
                X(:,col) = xx;
            end
            [yfit,yci] = lm.predict(X);
            
            h = plot(x,y,'bx', varargin{:});
            ax = ancestor(h,'axes');
            
            
            washold = ishold(ax);
            hold(ax,'on')
            h = [h; plot(ax,xx,yfit,'r-' ,xx,yci,'r:')];
            if ~washold
                hold(ax,'off')
            end
            
            if iscat
                set(ax,'XTick',tickloc','XTickLabel',ticklab);
                set(ax,'XLim',[tickloc(1)-0.5, tickloc(end)+0.5]);
            end
            
            yname = lm.ResponseName;
            title(ax,sprintf('%s',getString(message('stats:LinearModel:sprintf_AvsB',yname,xname))),'Interpreter','none');
            set(xlabel(ax,xname),'Interpreter','none');
            set(ylabel(ax,yname),'Interpreter','none');
            legend(ax,h(1:3),getString(message('stats:LinearModel:legend_Data')), ...
                getString(message('stats:LinearModel:legend_Fit')), ...
                getString(message('stats:LinearModel:legend_ConfidenceBounds')), ...
                'location','best')
            
            % Define data tips
            internal.stats.addLabeledDataTip(ObsNames,h(1),h(2:end));
        end
        
        function model = fitter(model)
            X = getData(model);
            [model.Design,model.CoefTerm,model.CoefficientNames] = designMatrix(model,X);
            
            % Populate the design_r field in the WorkingValues structure
            dr = create_design_r(model);
            model.WorkingValues.design_r = dr;
            model.DesignMeans = mean(dr,1);
            
            if isempty(model.Robust)
                [model.Coefs,model.MSE,model.CoefficientCovariance,model.R,model.Qy,model.DFE,model.Rtol,Q1] ...
                    = lsfit(model.design_r,model.y_r,model.w_r);
                h = zeros(size(model.ObservationInfo,1),1);
                h(model.ObservationInfo.Subset) = sum(abs(Q1).^2,2);
                model.Leverage = h;
            else
                [model.Coefs,stats] ...
                    = robustfit(model.design_r,model.y_r,model.Robust.RobustWgtFun,model.Robust.Tune,'off',model.w_r,false);
                model.CoefficientCovariance = stats.covb;
                model.DFE = stats.dfe;
                model.MSE = stats.s^2;
                model.Rtol = stats.Rtol;
                
                w = NaN(size(model.ObservationInfo,1),1);
                w(model.ObservationInfo.Subset) = stats.w;
                model.Robust.Weights = w;
                
                model.R = stats.R;
                model.Qy = stats.Qy;
                % We do not do the following because the leverage
                % calculation within statrobustfit is based on the least
                % squares results and is intended only for use during the
                % robust fitting.
%                 h = zeros(size(model.ObservationInfo,1),1);
%                 h(model.ObservationInfo.Subset) = stats.h;
            end
        end
        function model = postFit(model)
            % Do housework after fitting
            model = postFit@classreg.regr.TermsRegression(model);
            
            % Override SSE and SST to take any robust fitting into account
            model.SSE = model.DFE * model.MSE;
            model.SST = model.SSR + model.SSE;
            
            % Determine if model is hierarchical, and get the means of any
            % terms that are missing from the hierarchy
            model = getTermMeans(model);
        end
        
        
        % --------------------------------------------------------------------
        function D = get_diagnostics(model,type)
            compactNotAllowed(model,'Diagnostics',true);
            if nargin<2 % return all diagnostics in a table
                HatMatrix = get_diagnostics(model,'hatmatrix');
                CooksDistance = get_diagnostics(model,'cooksdistance');
                Dffits = get_diagnostics(model,'dffits');
                S2_i = get_diagnostics(model,'s2_i');
                Dfbetas = get_diagnostics(model,'dfbetas');
                CovRatio = get_diagnostics(model,'covratio');
                Leverage = model.Leverage;
                D = table(Leverage,CooksDistance,...
                    Dffits,S2_i,CovRatio,Dfbetas,HatMatrix,...
                    'RowNames',model.ObservationNames);
            else        % return a single diagnostic
                subset = model.ObservationInfo.Subset;
                switch(lower(type))
                    case 'leverage'
                        D = model.Leverage;
                        D(~subset,:) = 0;
                    case 'hatmatrix'
                        try
                            D = get_HatMatrix(model);
                        catch ME
                            warning(message('stats:LinearModel:HatMatrixError', ...
                                ME.message));
                            D = zeros(length(subset),0);
                        end
                        D(~subset,:) = 0;
                    case 'cooksdistance'
                        D = get_CooksDistance(model);
                        D(~subset,:) = NaN;
                    case 'dffits'
                        D = get_Dffits(model);
                        D(~subset,:) = NaN;
                    case 's2_i'
                        D = get_S2_i(model);
                        D(~subset,:) = NaN;
                    case 'dfbetas'
                        D = get_Dfbetas(model);
                        D(~subset,:) = 0;
                    case 'covratio'
                        D = get_CovRatio(model);
                        D(~subset,:) = NaN;
                    otherwise
                        error(message('stats:LinearModel:UnrecognizedDiagnostic', type));
                end
            end
        end
        function r = get_residuals(model,type)
            compactNotAllowed(model,'Residuals',true);
            if nargin < 2 % return all residual types in a table array
                Raw = get_residuals(model,'raw');
                Pearson = get_residuals(model,'pearson');
                Studentized = get_residuals(model,'studentized');
                Standardized = get_residuals(model,'standardized');
                r = table(Raw,Pearson,Studentized,Standardized, ...
                    'RowNames',model.ObservationNames);
            else % return a single type of residual
                subset = model.ObservationInfo.Subset;
                raw = getResponse(model) - predict(model);
                switch lower(type)
                    case 'raw'
                        r = raw;
                    case 'pearson'
                        r = raw ./ model.RMSE;
                    case 'studentized' % "externally studentized", using Delete 1 Variances
                        h = model.Leverage; % from parent class
                        s2_i = get_S2_i(model);
                        r = raw ./ sqrt(s2_i .* (1-h));
                    case 'standardized' % "internally studentized", using MSE
                        h = model.Leverage; % from parent class
                        r = raw ./ (sqrt(model.MSE * (1-h)));
                    otherwise
                        error(message('stats:LinearModel:UnrecognizedResidual', type));
                end
                r(~subset) = NaN;
            end
        end
        function [ok,meanx] = gettermmean(model,v,vnum,terminfo)
            % Get the mean of the design matrix for a term after removing one or more
            % variables from it
            
            % Try to get pre-calculated value from the compact object
            [ok,meanx] = gettermmean@classreg.regr.CompactLinearModel(model,v,vnum,terminfo);
            
            if ~ok
                % Remove this variable from the term to get a subterm, for example remove B
                % from A*B*C to get A*C
                v(vnum) = 0;
                
                % We have to compute the design matrix columns for this term
                X = model.Data;
                if isstruct(X)
                    X = X.X;      % use only the predictor data
                    v(end) = [];  % omit response column from term
                end
                design = classreg.regr.modelutils.designmatrix(X,'Model',v,'VarNames',model.Formula.VariableNames);
                meanx = mean(design,1);
            end
        end
        
        function [isrep,sspe,dfpe] = getReplicateInfo(model)
            % Used to get anova info based on replicates
            sspe = 0;   % sum of squares for pure error
            dfpe = 0;   % degrees of freedom for pure error
            if ~hasData(model)
                isrep = false;
            else
                subset = model.ObservationInfo.Subset;
                [sx,ix] = sortrows(model.Design(subset,:)); % better to sort X itself?
                isrep = [all(diff(sx)==0,2); false];
                sx = []; %#ok<NASGU> % no longer needed, save space
            end
            if any(isrep)
                first = 1;
                n = length(isrep);
                r = model.Residuals.Raw(subset);
                w = model.ObservationInfo.Weights(subset);
                while(first<n)
                    % find stretch of replicated observations
                    if ~isrep(first)
                        first = first+1;
                        continue;
                    end
                    for k=first+1:n
                        if ~isrep(k)
                            last = k;
                            break
                        end
                    end
                    
                    % Compute pure error SS and DF contributions from this stretch
                    t = ix(first:last);
                    r1 = r(t);
                    w1 = w(t);
                    m = sum(w1.*r1) / sum(w1);
                    sspe = sspe + sum(w1.*(r1-m).^2);
                    dfpe = dfpe + (last-first);
                    
                    % Continue beyond this stretch
                    first = last+1;
                end
                if dfpe==model.DFE
                    % Replications but no lack-of-fit, so treat as if no reps
                    isrep = false;
                end
            end
        end
    end % protected
    
    methods(Static, Access='public', Hidden)
        % The implementation of this method is in stepwise.m file.
        model = stepwise(X,varargin) % [X, y | DS], start, ...
        
        function model = fit(X,varargin)
            % Not intended to be called directly. Use FITLM to fit a LinearModel.
            %
            %   See also FITLM.
            [varargin{:}] = convertStringsToChars(varargin{:});
            [X,y,haveDataset,otherArgs] = LinearModel.handleDataArgs(X,varargin{:});
            
            % VarNames are optional names for the X matrix and y vector.  A
            % dataset/table defines its own list of names, so this is not accepted
            % with a dataset/table.
            
            % PredictorVars is an optional list of the subset of variables to
            % actually use as predictors in the model, and is only needed with
            % an alias.  A terms matrix or a formula string already defines
            % which variables to use without that.  ResponseVar is an optional
            % name that is not needed with a formula string.
            
            % rankwarn is undocumented and is used during stepwise fitting
            
            paramNames = {'Intercept' 'PredictorVars' 'ResponseVar' ...
                'Weights' 'Exclude' 'CategoricalVars' 'VarNames'...
                'RobustOpts' 'DummyVarCoding' 'rankwarn'};
            paramDflts = {[] [] [] [] [] [] [] [] 'reference' true};
            
            % Default model is main effects only.
            if isempty(otherArgs)
                modelDef = 'linear';
            else
                arg1 = otherArgs{1};
                if mod(length(otherArgs),2)==1 % odd, model followed by pairs
                    modelDef = arg1;
                    otherArgs(1) = [];
                elseif internal.stats.isString(arg1) && ...
                        any(strncmpi(arg1,paramNames,length(arg1)))
                    % omitted model but included name/value pairs
                    modelDef = 'linear';
                end
            end
            
            [intercept,predictorVars,responseVar,weights,exclude, ...
                asCatVar,varNames,robustOpts,dummyCoding,rankwarn,supplied] = ...
                internal.stats.parseArgs(paramNames, paramDflts, otherArgs{:});
            
            model = LinearModel();
            
            model.Robust = classreg.regr.FitObject.checkRobust(robustOpts);
            model.Formula = LinearModel.createFormula(supplied,modelDef,X, ...
                predictorVars,responseVar,intercept,varNames,haveDataset);
            model = assignData(model,X,y,weights,asCatVar,dummyCoding,model.Formula.VariableNames,exclude);
            
            silent = classreg.regr.LinearFormula.isModelAlias(modelDef);
            model = removeCategoricalPowers(model,silent);
            
            model = doFit(model);
            
            model = updateVarRange(model); % omit excluded points from range
            
            if rankwarn
                checkDesignRank(model);
            end
        end   
        
    end % static public hidden
    
    methods(Static, Hidden)
        function formula = createFormula(supplied,modelDef,X,predictorVars,responseVar,intercept,varNames,haveDataset)
            supplied.Link = false;
            formula = classreg.regr.TermsRegression.createFormula(supplied,modelDef, ...
                X,predictorVars,responseVar,intercept,'identity',varNames,haveDataset);
        end
    end % static protected
end

% ----------------------------------------------------------------------------
function logy = normlogpdf(x,mu,sigma)
logy = (-0.5 * ((x - mu)./sigma).^2) - log(sqrt(2*pi) .* sigma);
end



% ----------------------------------------------------------------------------
function [b,mse,S,R1,Qy1,dfe,Rtol,Q1] = lsfit(X,y,w)
% LSFIT Weighted least squares fit

[nobs,nvar] = size(X); % num observations, num predictor variables

% Weights not given, assume equal.
if nargin < 3 || isempty(w)
    w = [];
    
    % Weights given.
elseif isvector(w) && numel(w)==nobs && all(w>=0)
    D = sqrt(w(:));
    X = bsxfun(@times,D,X);
    y = bsxfun(@times,D,y);
    % w is OK
    
else
    error(message('stats:LinearModel:InvalidWeights', nobs));
end

outClass = superiorfloat(X,y,w);

% Factor the design matrix and transform the response vector.
[Q,R,perm] = qr(X,0);
Qy = Q'*y;

% Use the rank-revealing QR to remove dependent columns of X.
if isempty(R)
    Rtol = 1;
    keepCols = zeros(1,0);
else
    % use tolerance used by fullQRfactor 
    scaleT = max(nobs,nvar).*eps(class(R));  % here ScaleT will increase linearly with data size
    scaleT = min(scaleT, sqrt(eps(class(R)))); % Cap scaleT to roughly 1e-8 for double and 1e-4 in single
    Rtol = abs(R(1)).*scaleT;
    if isrow(R)
        keepCols = 1;
    else
        keepCols = find(abs(diag(R)) > Rtol);
    end
end

rankX = length(keepCols);
R0 = R;
perm0 = perm;
if rankX < nvar
    R = R(keepCols,keepCols);
    Qy = Qy(keepCols,:);
    perm = perm(keepCols);
end

% Compute the LS coefficients, filling in zeros in elements corresponding
% to rows of R that were thrown out.
b = zeros(nvar,1,outClass);
b(perm,1) = R \ Qy;

if nargout > 1
    % Compute the MSE.
    dfe = nobs - rankX;
    if dfe > 0
        sst = sum(y.*conj(y),1);
        ssx = sum(Qy.*conj(Qy),1);
        mse = max(0, sst-ssx) ./ dfe;
    else % rankX == nobs, and so Xb == y exactly
        mse = zeros(1,1,outClass);
    end
    
    % Compute the covariance matrix of the LS estimates.  Fill in zeros
    % corresponding to exact zero coefficients.
    Rinv = R \ eye(rankX,outClass);
    if nargout > 2
        S = zeros(nvar,nvar,outClass);
        S(perm,perm) = Rinv*Rinv' .* mse; % guaranteed to be hermitian
    end
    
    % Return unpermuted, unreduced versions of Q*y and R
    if nargout > 3
        Qy1 = zeros(nvar,1);
        Qy1(perm,1) = Qy;
        R1 = zeros(nvar,nvar,outClass);
        R1(perm,perm0) = R0(keepCols,:);
        Q1 = zeros(size(X),outClass);
        Q1(:,perm) = Q(:,keepCols);
    end
end
end
