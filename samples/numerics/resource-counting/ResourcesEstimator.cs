// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Data;
using System.Diagnostics;
using System.Linq;
using System.Reflection;
using System.Text;
using Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime;
using Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators;

namespace Microsoft.Quantum.Simulation.Samples
{
    /// <summary>
    /// The ResourceEstimator estimates statistics about how many resources
    /// the given operation needs for execution.
    /// The resources it calculates are:
    /// <ol>
    ///   <li>Primitive operations count</li>
    ///   <li>Qubits depth (max number of qubits allocated at any given point)</li>
    ///   <li>Gates width (total number of gates used for the computation)</li>
    /// </ol>
    /// </summary>
    public partial class ResourcesEstimator : QCTraceSimulator
    {
        /// <summary>
        /// The ResourceEstimator is based on <see cref="QCTraceSimulator"/>; this returns
        /// the correct configuration expected by the ResourceEstimator and what get used when
        /// a new instance is created with no parameters. It is
        /// optimized for performance and metrics collection.
        /// </summary>
        public static QCTraceSimulatorConfiguration RecommendedConfig() =>
            new QCTraceSimulatorConfiguration
            {
                CallStackDepthLimit = 1,

                ThrowOnUnconstrainedMeasurement = false,
                UseDistinctInputsChecker = false,
                UseInvalidatedQubitsUseChecker = false,

                UsePrimitiveOperationsCounter = true,
                UseDepthCounter = true,
                UseWidthCounter = true
            };

        /// <summary>
        /// Constructor used by entry point driver to provide the assembly for core types that
        /// need to be overriden.
        /// </summary>
        public ResourcesEstimator(Assembly coreAssembly) : base(RecommendedConfig(), coreAssembly)
        {
        }

        /// <summary>
        /// Parameter-less constructor. It initializes the ResourceEstimator
        /// with a QCTraceSimulatorConfiguration as returned by <see cref="RecommendedConfig"/>.
        /// </summary>
        public ResourcesEstimator() : this(RecommendedConfig())
        {
        }

        /// <summary>
        /// It initializes the ResourceEstimator with the given QCTraceSimulatorConfiguration.
        /// It is recommended to use <see cref="RecommendedConfig"/> to create a new config instance
        /// and tweak it, to make sure the data collection is correctly configured.
        /// </summary>
        public ResourcesEstimator(QCTraceSimulatorConfiguration config) : base(config)
        {
        }

        // Exposed the underlying CoreConfiguration for unittesting.
        internal QCTraceSimulatorCoreConfiguration CoreConfig => tCoreConfig;

        /// <summary>
        /// Returns the label to use for the given metric. If the metric should be skipped
        /// it returns null. Otherwise, it returns the same metric's name or some other alias.
        /// </summary>
        public virtual string GetMetricLabel(string name)
        {
            if (name == MetricsNames.DepthCounter.StartTimeDifference ||
                name == MetricsNames.WidthCounter.InputWidth ||
                name == MetricsNames.WidthCounter.ReturnWidth)
            {
                return null;
            }
            else if (name == MetricsNames.WidthCounter.ExtraWidth)
            {
                return "QubitCount";
            }
            else
            {
                return name;
            }
        }

        /// <summary>
        /// <para>Returns the values collected as a DataTable with the first
        /// column two columns: the metric name and its value.
        /// The metric name column is marked as PrimaryKey
        /// for easy access.
        /// </para>
        /// <para>
        /// The table looks like this:
        /// <pre>
        ///  -------------------------
        ///  | Metric        | Sum   |
        ///  -------------------------
        ///  | QubitsCount   | 100   |
        ///  | T             | 10000 |
        ///  ...
        ///  -------------------------
        /// </pre>
        /// </para>
        /// </summary>
        public virtual DataTable Data
        {
            get
            {
                var table = new DataTable();

                table.Columns.Add(new DataColumn { DataType = typeof(string), ColumnName = "Metric" });
                table.Columns.Add(new DataColumn { DataType = typeof(double), ColumnName = "Sum" });
                table.Columns.Add(new DataColumn { DataType = typeof(double), ColumnName = "Max" });
                table.PrimaryKey = new DataColumn[] { table.Columns[0] };

                foreach (var l in CoreConfig.Listeners)
                {
                    // All listeners we expected are ICallGraphStatistics
                    if (l is ICallGraphStatistics collector)
                    {
                        var results = collector.Results.ToTable();
                        Debug.Assert(results.keyColumnNames.Length > 2 && results.keyColumnNames[2] == "Caller");

                        var roots = results.rows.Where(r => r.KeyRow[2] == CallGraphEdge.CallGraphRootHashed);
                        var sum_idx = Array.FindIndex(results.statisticsNames, n => n == "Sum");
                        var max_idx = Array.FindIndex(results.statisticsNames, n => n == "Max");

                        for (var m_idx = 0; m_idx < results.metricNames.Length; m_idx++)
                        {
                            var label = GetMetricLabel(results.metricNames[m_idx]);
                            if (label == null) continue;

                            DataRow row = table.NewRow();
                            row["Metric"] = label;

                            if (sum_idx >= 0)
                            {
                                Double sum = 0;
                                foreach (var r in roots)
                                {
                                    sum += r.DataRow[m_idx, sum_idx];
                                }
                                row["Sum"] = sum;
                            }

                            if (max_idx >= 0) {
                                Double max = 0; // all our metrics are positive
                                foreach (var r in roots) {
                                    max = System.Math.Max(max, r.DataRow[m_idx, max_idx]);
                                }
                                row["Max"] = max;
                            }

                            table.Rows.Add(row);
                        }
                    }
                    else
                    {
                        Debug.Assert(false, "Listener is not a collector");
                    }
                }

                return table;
            }
        }

        /// <summary>
        /// Returns <see cref="Data"/> in TSV format where the key is the Metric name,
        /// and the value is the statistics in tab-seperated format.
        /// </summary>
        public virtual string ToTSV()
        {
            var content = new StringBuilder();
            var table = Data;

            content.Append(table.Columns[0].ColumnName.PadRight(15)).Append('\t');
            var columns = table.Columns.Cast<DataColumn>().Skip(1).Select(c => c.ColumnName.PadRight(15));
            content.Append(string.Join("\t", columns));

            foreach(DataRow r in table.Rows)
            {
                content.Append('\n');
                content.Append(r[0].ToString().PadRight(15)).Append('\t');
                content.Append(string.Join("\t", r.ItemArray.Skip(1).Select(i => i.ToString())));
            }

            return content.ToString();
        }
    }
}
